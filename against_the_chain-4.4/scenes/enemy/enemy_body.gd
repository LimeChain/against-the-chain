extends CharacterBody2D
var player

func _ready() -> void:
	player = get_node("/root/World/Player")
	# draw the bar once at start
	queue_redraw()
func _process(delta: float) -> void:
	look_at(player.position)
