extends Node2D
 
@export var max_enemies = 100
var enemy_scene: PackedScene
var captain_enemy_scene: PackedScene
var enemies := []
var normal_enemies_counter := 0
var is_captain_ritual := false

func _ready():
	enemy_scene = preload("res://scenes/enemies/enemy/enemy.tscn")
	captain_enemy_scene = preload("res://scenes/enemies/captain_enemy/captain_enemy.tscn")
	$SpawnTimer.wait_time = randf_range(0.5, 3.0)
	$SpawnTimer.start()

func spawn_enemy(position: Vector2):
	if enemies.size() >= max_enemies:
		return
	var enemy
	if normal_enemies_counter == 5 and not enemies.any(func (enemy): return enemy.name == "CaptainEnemy"):
		is_captain_ritual = true
		enemy = captain_enemy_scene.instantiate()
		normal_enemies_counter = 0 
	else: 
		enemy = enemy_scene.instantiate()
	normal_enemies_counter += 1
	if is_captain_ritual:
		if find_captain(enemies):
			enemy.position = find_captain(enemies).position
	else:
		enemy.position = position
	enemy.add_to_group("enemies")
	enemy.dead.connect(_on_enemy_died)
	enemy.shoot.connect(_on_enemy_shoot)
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
	if enemy.name == "CaptainEnemy":
		is_captain_ritual = false
	remove_enemy(enemy)

	

func find_captain(enemies:Array):
	for enemy in enemies:
		if enemy.name == "CaptainEnemy":
			return enemy
			
func _on_enemy_shoot(position:Vector2, enemy_pos:Vector2):
	var direction = ($"../Player".position - enemy_pos).normalized()
	$"../EnemyProjectileManager".spawn_projectile(position,direction)
