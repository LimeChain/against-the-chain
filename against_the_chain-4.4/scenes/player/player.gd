extends CharacterBody2D

const MAX_HEALTH = 100
const SPEED = 1000
const DAMAGE_INTERVAL = 1

var can_shoot:bool = true
var health: int
var takes_damage = false
var damage_taken_amount = 0
var time_since_damage = 0


signal player_shoot(pos:Vector2, direction:Vector2)
signal player_dead()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position= Vector2.ZERO
	health = MAX_HEALTH


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var normal = Input.get_vector("left", "right","up","down")
	velocity = normal * SPEED
	move_and_slide()
	shoot(delta)
	look_at(get_global_mouse_position())
	if time_since_damage >= DAMAGE_INTERVAL:
		time_since_damage = 0
		if takes_damage:
			health-=damage_taken_amount
			print(health)
			if health <=0:
				player_dead.emit()
				print("player is dead")
	time_since_damage += delta

func shoot(delta:float)-> void:
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		$ShootTimer.start()
		var projectile_starts = $ShootingPoints.get_children()
		var selected_start_point = projectile_starts[randi()%projectile_starts.size()]
		var direction = (get_global_mouse_position() - position).normalized()
		player_shoot.emit(selected_start_point.global_position, direction)


func _on_shoot_timer_timeout() -> void:
	can_shoot = true # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	takes_damage = true
	var enemy = area.get_parent()
	if enemy.is_in_group("enemies"):
		var damage = enemy.damage
		damage_taken_amount = damage
		takes_damage = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	damage_taken_amount = 0
	takes_damage = false
