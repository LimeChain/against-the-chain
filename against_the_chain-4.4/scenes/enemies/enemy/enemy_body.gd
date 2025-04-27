extends Node2D
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("/root/World/Player")
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(player.position)
