extends Node

var validators = [
	"JupRhwjrF5fAcs6dFhLH59r3TJFvbcyLP2NRM8UGH9H",
	"5pPRHniefFjkiaArbGX3Y8NUysJmQ9tMZg3FrFGwHzSm",
	"DRpbCBMxVnDK7maPM5tGv6MvB3v1sRMC86PZ8okm21hy",
	"krakeNd6ednDPEXxHAmoBs1qKVM8kLg79PvWF2mhXV1",
	"q9XWcZ7T1wP4bW9SB4XgNNwjnFEJ982nE8aVbbNuwot",
	"HEL1USMZKAL2odpNBj2oCjffnFGaYwmbGmyewGv1e2TU",
	"DtdSSG8ZJRZVv5Jx7K1MeWp7Zxcu19GD5wQRGRpQ9uMF",
	"9W3QTgBhkU4Bwg6cwnDJo6eGZ9BtZafSdu1Lo9JmWws7",
	"CW9C7HBwAMgqNdXkNgFg9Ujr3edR2Ab9ymEuQnVacd1A",
	"XkCriyrNwS3G4rzAXtG5B1nnvb5Ka1JtCku93VqeKAr",
	"EgxVyTgh2Msg781wt9EsqYx4fW8wSvfFAHGLaJQjghiL",
	"9W3QTgBhkU4Bwg6cwnDJo6eGZ9BtZafSdu1Lo9JmWws7",
	"722RdWmHC5TGXBjTejzNjbc8xEiduVDLqZvoUGz6Xzbp",
	"CXPeim1wQMkcTvEHx9QdhgKREYYJD8bnaCCqPRwJ1to1"
]

var block_counter = 0
var previous_block_transaction_count = -1
var current_block_transaction_count = -1
var current_block_number = -1
var missed_count = 0
signal create_enemy(type: String)
signal get_pissed_off(level: int)

func _handle_block_created (blockhash: String) -> void :
	#if block_counter < 10 :
		#block_counter+=1
	_create_default_enemy()

	#else:
		#
		#block_counter = 0
	#pass

func _create_default_enemy():
	emit_signal("create_enemy", "default")
	pass

func _handle_block_leader (leader: String):
	if leader in validators:
		emit_signal("create_enemy", "captain")
		return
	missed_count +=1
	pass # Replace with function body.

func _process(delta: float) -> void:
	if missed_count == 5 :
		for x in range(10):
			emit_signal("create_enemy", "bug")
		missed_count = 0
	pass


func _on_web_socket_client_block_blockhash(data: String) -> void:
	pass # Replace with function body.
