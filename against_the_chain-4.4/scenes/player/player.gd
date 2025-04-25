extends CharacterBody2D

var can_shoot:bool = true
const speed = 1000

signal player_shoot(pos:Vector2, direction:Vector2)
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#position= Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var normal = Input.get_vector("left", "right","up","down")
	velocity = normal * speed
	move_and_slide()
	shoot(delta)
	look_at(get_global_mouse_position())


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
