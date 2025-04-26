extends Node2D
var player

func _ready() -> void:
	player = get_node("/root/World/Player")
	# draw the bar once at start
	queue_redraw()
func _process(delta: float) -> void:
	var enemy_manager = get_parent().get_parent()
	if enemy_manager.is_captain_ritual:
		var captain = enemy_manager.find_captain(enemy_manager.enemies)
		#look_at(captain.position)
	else:
		look_at(player.position)
