extends Area2D
@export var speed = 200
@export var health = 3
var player

signal dead(enemy: Area2D)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# random position on the world
	player = get_node("/root/World/Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	look_at(player.position)
	position += (player.position - position).normalized() * speed * delta



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectiles"):
		health-=1
		if health <= 0:
			dead.emit(self)
