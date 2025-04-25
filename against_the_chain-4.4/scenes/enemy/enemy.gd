extends CharacterBody2D

@export var speed = 200
@export var health = 3
@export var damage = 1
var player

signal dead(enemy: Area2D)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.area_entered.connect(_on_area_entered)
	player = get_node("/root/World/Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(player.position)
	position += (player.position - position).normalized() * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectiles"):
		area.destroy.emit(area)
		health-=1
		if health <= 0:
			dead.emit(self)
