extends Node2D

@export var max_enemies = 5
var enemy_scene: PackedScene
var enemies := []


func _ready():
	enemy_scene = preload("res://scenes/enemy/enemy.tscn")
	$SpawnTimer.start()

func spawn_enemy(position: Vector2):
	if enemies.size() >= max_enemies:
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
	
func _on_enemy_died(enemy: CharacterBody2D):
	remove_enemy(enemy)
