extends Node2D
var enemy_scene: PackedScene
var enemies := []
@export var max_enemies = 20

func _ready():
	print('manager is ready')
	enemy_scene = preload("res://scenes/enemy/enemy.tscn")
	$SpawnTimer.start()

func spawn_enemy(position: Vector2):
	if enemies.size() > max_enemies:
		return
	var enemy = enemy_scene.instantiate()
	enemy.position = position
	enemy.add_to_group("enemies")
	enemy.dead.connect(_on_enemy_died)
	enemies.append(enemy)
	add_child(enemy)

func remove_enemy(enemy: Node):
	enemies.erase(enemy)
	enemy.queue_free()

func clear_all_enemies():
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()
	
func _on_enemy_died(enemy: Area2D):
	print("dead signal")
	print(enemies.size())
	remove_enemy(enemy)
