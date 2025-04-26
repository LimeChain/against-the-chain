extends Node2D

var projectile_scene: PackedScene
var projectiles := []

@export var max_projectiles = 200

func _ready():
	projectile_scene = preload("res://scenes/projectiles/projectile.tscn")

func spawn_projectile(position: Vector2, direction:Vector2):
	if projectiles.size() > max_projectiles:
		return
	var projectile = projectile_scene.instantiate()
	projectile.get_child(1).visible = false
	projectile.get_child(3).visible = true
	projectile.position = position
	projectile.direction_to_shoot = direction
	#projectile.get_node(NodePath("./$AnimatedSprite2D")).play("Idle")
	projectile.rotation_degrees = rad_to_deg(direction.angle()) + 90
	projectile.add_to_group("projectiles")
	projectile.destroy.connect(_on_projectile_destroyed)
	
	
	projectiles.append(projectile)
	add_child(projectile)

func remove_projectile(projectile: Node):
	projectiles.erase(projectile)
	projectile.queue_free()

func clear_all_projectiles():
	for projectile in projectiles:
		projectile.queue_free()
	projectiles.clear()

func _on_projectile_destroyed(projectile: Area2D):
	var sprite = projectile.get_node("AnimatedSprite2D")  # use name, or still get_child(3) if you want
	
	sprite.play("Explode")
	projectile.speed = 0

	sprite.animation_looped.connect(func():
		sprite.stop()
		remove_projectile(projectile)
	)


func _on_player_player_shoot(pos: Vector2, direction: Vector2) -> void:
	spawn_projectile(pos, direction)
