extends Node

# Network configuration
const PORT = 9999
const MAX_PLAYERS = 4
var peer: ENetMultiplayerPeer
var is_server := false
var my_id := 0
var next_peer_id := 2  # Start from 2 since server is 1

# Game state synchronization
var game_state = {
	"players": {},
	"enemies": [],
	"projectiles": []
}

# Player indicators
var player_indicators = {}

# Signals
signal player_joined(player_id: int)
signal player_left(player_id: int)
signal game_state_updated(state: Dictionary)
signal peer_ready
signal peer_id_assigned(id: int)

func _init() -> void:
	# Only variable initialization here, no multiplayer code!
	pass

func is_server_running(ip: String, port: int) -> bool:
	var test_peer = ENetMultiplayerPeer.new()
	var error = test_peer.create_client(ip, port)
	if error != OK:
		return false
	
	# Try to connect and wait briefly
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < 1000:  # Wait up to 1 second
		test_peer.poll()
		if test_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
			test_peer.close()
			return true
		await get_tree().create_timer(0.1).timeout
	
	test_peer.close()
	return false

func _ready() -> void:
	# All multiplayer setup here
	peer = ENetMultiplayerPeer.new()
	peer.set_bind_ip("*")
	
	# First check if a server is already running
	if await is_server_running("127.0.0.1", PORT):
		print("Server already running, connecting as client...")
		var error = peer.create_client("127.0.0.1", PORT)
		if error != OK:
			push_error("Failed to create multiplayer connection")
			return
		print("Created client")
		multiplayer.multiplayer_peer = peer
		# Connect to multiplayer signals for client
		multiplayer.connected_to_server.connect(_on_connection_succeeded)
		multiplayer.connection_failed.connect(_on_connection_failed)
	else:
		print("No server found, creating new server...")
		var error = peer.create_server(PORT, MAX_PLAYERS)
		if error == OK:
			print("Created server")
			is_server = true
			my_id = 1
			multiplayer.multiplayer_peer = peer
			_on_connection_succeeded()
			emit_signal("peer_id_assigned", my_id)
		else:
			push_error("Failed to create server")
			return
	
	# Always connect peer_connected/disconnected
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Connect to game state updates to print other players' positions
	game_state_updated.connect(_on_game_state_updated)

func _on_connection_succeeded() -> void:
	print("Connection succeeded")
	if is_server:
		print("I am the SERVER with ID: ", my_id)
	else:
		print("I am a CLIENT with ID: ", my_id)
	
	emit_signal("peer_ready")

func _on_connection_failed() -> void:
	push_error("Failed to establish connection")
	peer = null

@rpc("any_peer", "reliable")
func request_peer_id() -> void:
	if is_server:
		var requester_id = multiplayer.get_remote_sender_id()
		rpc_id(requester_id, "assign_peer_id", next_peer_id)
		next_peer_id += 1

@rpc("authority", "reliable")
func assign_peer_id(id: int) -> void:
	my_id = id
	emit_signal("peer_id_assigned", my_id)

func _on_peer_connected(id: int) -> void:
	print("Player connected with client ID: ", id)
	if is_server:
		print("Server successfully connected with client ID: ", id)
	emit_signal("player_joined", id)
	# Send current game state to new player
	rpc_id(id, "sync_game_state", game_state)
	# Create indicator for new player using their client ID
	_create_player_indicator(id)

func _on_peer_disconnected(id: int) -> void:
	print("Player disconnected with client ID: ", id)
	emit_signal("player_left", id)
	game_state.players.erase(id)
	# Remove indicator for disconnected player
	_remove_player_indicator(id)

@rpc("any_peer", "reliable")
func update_player_state(player_data: Dictionary) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	print("Received player state update from client ID: ", sender_id, " position: ", player_data.position)
	game_state.players[sender_id] = player_data
	emit_signal("game_state_updated", game_state)
	# If we're the server, sync the updated state to all clients
	if is_server:
		rpc("sync_game_state", game_state)

@rpc("any_peer", "reliable")
func sync_game_state(state: Dictionary) -> void:
	print("Syncing game state, players: ", state.players.size())
	game_state = state
	emit_signal("game_state_updated", game_state)

func print_other_players_positions() -> void:
	for player_id in game_state.players:
		if player_id != my_id:  # Skip our own player
			var player_data = game_state.players[player_id]
			print("Player ", player_id, " position: ", player_data.position)

func _on_game_state_updated(_state: Dictionary) -> void:
	print_other_players_positions()
	# Update all player indicators using client IDs
	for client_id in game_state.players:
		if client_id != my_id:
			var player_data = game_state.players[client_id]
			if player_indicators.has(client_id):
				player_indicators[client_id].update_position(player_data.position)
				print("Updated position for client ID: ", client_id, " to: ", player_data.position)
			else:
				print("Creating new indicator for client ID: ", client_id)
				_create_player_indicator(client_id)

func _create_player_indicator(player_id: int) -> void:
	if player_id == my_id:
		return  # Don't create indicator for self
		
	print("Creating indicator for client ID: ", player_id)
	var indicator = preload("res://scenes/player/player_indicator.tscn").instantiate()
	indicator.player_id = player_id
	# Generate a unique color based on client ID
	var hue = float(player_id) / float(MAX_PLAYERS)
	indicator.color = Color.from_hsv(hue, 0.8, 0.8)
	
	# Add to the current scene instead of root
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(indicator)
		player_indicators[player_id] = indicator
		print("Successfully added indicator for client ID: ", player_id)
	else:
		print("ERROR: Could not find current scene to add indicator")

func _remove_player_indicator(player_id: int) -> void:
	if player_indicators.has(player_id):
		player_indicators[player_id].queue_free()
		player_indicators.erase(player_id)
