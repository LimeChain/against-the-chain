class_name WebsocketClient extends Node

var client = SocketIOClient
var backendURL: String

signal block_slot(data: int)
signal block_blockhash(data: String)
signal block_reward(data: String)
signal block_timestamp(data: int)
signal block_transactionCount (data:int)
signal block_totalTransactions (data: int)
signal socket_connected
func _ready():
	# prepare URL
	backendURL = "ec2-34-205-69-138.compute-1.amazonaws.com:80/socket.io/"

	# initialize client
	client = SocketIOClient.new(backendURL)
	
	# this signal is emitted when the socket is ready to connect
	client.on_engine_connected.connect(on_socket_ready)

	# this signal is emitted when socketio server is connected
	client.on_connect.connect(on_socket_connect)

	# this signal is emitted when socketio server sends a message
	client.on_event.connect(on_socket_event)

	# add client to tree to start websocket
	add_child(client)

func _exit_tree():
	# optional: disconnect from socketio server
	client.socketio_disconnect()

func on_socket_ready(_sid: String):
	# connect to socketio server when engine.io connection is ready
	client.socketio_connect()

func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		print("Failed to connect to backend!")
	else:
		print("Socket connected")



func on_socket_event(event_name: String, block_data: Variant, _name_space):
	block_slot.emit(block_data.slot)
	block_blockhash.emit(block_data.blockhash)
	block_reward.emit(block_data.reward)
	block_timestamp.emit(block_data.timestamp)
	block_transactionCount.emit(block_data.transactionCount)
	block_totalTransactions.emit(block_data.totalTransactions)
