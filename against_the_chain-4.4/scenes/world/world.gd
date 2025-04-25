extends Node2D

# Preloads
const projectile: PackedScene = preload("res://scenes/projectile/projectile.tscn")
const enemy: PackedScene = preload("res://scenes/enemy/enemy.tscn")
const EnemyManager = preload("res://scripts/enemy_manager.gd")

# Values
@export var zoom_speed = 0.1
var camera: Camera2D
var ZOOM_MAX =2
var ZOOM_MIN =1
var can_spawn = true
const WORLD_WIDTH = 8046
const WORLD_HEIGHT = 8046

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = $Player/Camera2D
	camera.zoom = Vector2(ZOOM_MIN, ZOOM_MIN)

func _process(delta:float):
	_spawn_enemies()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if camera.zoom >= Vector2(ZOOM_MIN,ZOOM_MIN):
					camera.zoom -= Vector2(zoom_speed, zoom_speed)
			MOUSE_BUTTON_WHEEL_DOWN:
				if camera.zoom <= Vector2(ZOOM_MAX,ZOOM_MAX):
					camera.zoom += Vector2(zoom_speed, zoom_speed)


#func _on_player_player_shoot(pos: Variant, direction: Variant) -> void:
	#var projectile = projectile.instantiate()
	#projectile.position = pos
	#projectile.direction_to_shoot = direction
	#projectile.rotation_degrees = rad_to_deg(direction.angle()) + 90
	#projectile.add_to_group("projectiles")
	#$Projectiles.add_child(projectile)

func _spawn_enemies():
	if can_spawn:
		$EnemyManager.spawn_enemy(Vector2.ZERO)
		can_spawn = false

#func _spawn_projectiles():
	#pass
	

func _on_spawn_timer_timeout() -> void:
	can_spawn = true
