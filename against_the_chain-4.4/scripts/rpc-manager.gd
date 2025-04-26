# File: RPCWebsocket.gd
# → Add this as an Autoload singleton (e.g. named "RPCWebsocket")

extends Node

const WS_URL := "wss://api.mainnet-beta.solana.com/"

var ws: WebSocketPeer

signal slot_message_received(slot_data: Dictionary)

func _ready():
	ws = WebSocketPeer.new()
	# Start the connection
	var err = ws.connect_to_url(WS_URL)
	if err != OK:
		push_error("WebSocket connection failed: %s" % err)
		return
	# Pump the socket in process
	set_process(true)

func _process(delta):
	ws.poll()
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		# Send subscribe once, after opening
		if not ws.was_string_packet():  # crude “first‐open” check
			var req = {
				"jsonrpc":"2.0",
				"id":1,
				"method":"slotSubscribe",
			}
			ws.send_text(JSON.stringify(req))
		# Read all incoming messages
		while ws.get_available_packet_count() > 0:
			var packet = ws.get_packet()
			var text   = packet.get_string_from_utf8()
			_handle_ws_message(text)

func _handle_ws_message(txt: String) -> void:
	var j = JSON.new()
	if j.parse(txt) != OK:
		push_error("Invalid WS JSON: %s" % j.get_error_message())
		return
	var msg = j.data
	# subscription confirmation
	if int(msg.id) == 1 and msg.has("result"):
		print("Subscribed to slot, sub id=", msg.result)
	# slot notification
	if msg.error :
		push_error("Message Error: %s" % msg.error)
		return
	if msg.method == "slotSubscribe":
		var slot = msg.params.result.slot
		print(slot)
		emit_signal("slot_message_received", slot)
