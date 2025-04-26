extends Node2D

const WORLD_WIDTH = 8046
const WORLD_HEIGHT = 8046
const ZOOM_MAX = 2
const ZOOM_MIN = 1
# Preloads
const projectile: PackedScene = preload("res://scenes/projectiles/projectile.tscn")
const enemy: PackedScene = preload("res://scenes/enemies/enemy/enemy.tscn")
const EnemyManager = preload("res://scripts/enemy_manager.gd")
const obstacle: PackedScene = preload("res://scenes/obstacles/obstacle.tscn")
# Values
@export var zoom_speed = 0.1
@export var enemy_spawn_radius = 1300
var camera: Camera2D
var can_spawn = true

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


func _spawn_enemies():
	if can_spawn:
		var spawm_position = get_random_point_in_circle($Player.position, enemy_spawn_radius)
		$EnemyManager.spawn_enemy(spawm_position)
		can_spawn = false
	

func _on_spawn_timer_timeout() -> void:
	can_spawn = true

func get_random_point_in_circle(origin: Vector2, radius: float) -> Vector2:
	var angle = randf() * TAU  # TAU = 2 * PI
	var r = sqrt(randf()) * radius
	var offset = Vector2(cos(angle), sin(angle)) * r
	return origin + offset
	
func add_random_obstacles () -> void: 
	
	pass
