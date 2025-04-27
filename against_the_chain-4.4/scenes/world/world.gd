extends Node2D

const WORLD_WIDTH = 8046
const WORLD_HEIGHT = 8046
const ZOOM_MAX = 2
const ZOOM_MIN = 1
const BAR_WIDTH  := 100
const BAR_HEIGHT := 12
const BAR_OFFSET := Vector2(0, -128)
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
var has_game_started = false

signal spawn_default_enemy (bounds: Vector2)
signal spawn_captain_enemy (bounds: Vector2)
signal spawn_bug404_enemy(bounds: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = $Player/Camera2D
	camera.zoom = Vector2(ZOOM_MIN, ZOOM_MIN)
	$Player/AudioManager/BackgroundMusic.play()

func _process(delta:float):
	if not has_game_started:
		return
	#_spawn_enemies()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if camera.zoom >= Vector2(ZOOM_MIN,ZOOM_MIN):
					camera.zoom -= Vector2(zoom_speed, zoom_speed)
			MOUSE_BUTTON_WHEEL_DOWN:
				if camera.zoom <= Vector2(ZOOM_MAX,ZOOM_MAX):
					camera.zoom += Vector2(zoom_speed, zoom_speed)


func _spawn_enemies(type: String):
		var north_west_limit = $SpawnLimits/NorthWest.position
		var south_east_limit = $SpawnLimits/SouthEast.position
		var spawn_position = get_random_point_in_rect(north_west_limit, south_east_limit)
		if (type == "captain"):
			$EnemyManager.spawn_captain_enemy(spawn_position)
		elif (type=="bug"):
			$EnemyManager.spawn_bug_enemy(spawn_position)
		else:
			$EnemyManager.spawn_default_enemy(spawn_position)

func get_random_point_in_rect(p1: Vector2, p2: Vector2) -> Vector2:
	var min_x = min(p1.x, p2.x)
	var max_x = max(p1.x, p2.x)
	var min_y = min(p1.y, p2.y)
	var max_y = max(p1.y, p2.y)

	var random_x = randf_range(min_x, max_x)
	var random_y = randf_range(min_y, max_y)

	return Vector2(random_x, random_y)
	
func add_random_obstacles () -> void: 
	
	pass


func _on_web_socket_client_socket_connected() -> void:
	$LoadingScreen.visible = false
	has_game_started = true
	
func _on_web_socket_client_block_blockhash(data: String) -> void:
	pass # Replace with function body.


func spawn_enemy(type: String) -> void:
	pass # Replace with function body.
