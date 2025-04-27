extends CharacterBody2D

const MAX_HEALTH = 100
const DAMAGE_INTERVAL = 1
const POSITION_UPDATE_INTERVAL = 0.05  # Update position every 0.1 seconds
const MIN_SPEED = 500
const MAX_SPEED = 1000
var speed = 1000
var can_shoot:bool = true
var health: int
var takes_damage = false
var damage_taken_amount = 0
var time_since_damage = 0
var projectile_damage = 5
var normal: Vector2
var time_since_position_update = 0


signal player_shoot(pos:Vector2, direction:Vector2)
signal player_dead()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position= Vector2.ZERO
	health = MAX_HEALTH
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not $"..".has_game_started:
		return
	normal = Input.get_vector("left", "right","up","down")
	handle_direction()
	velocity = normal * speed
	move_and_slide()
	
	shoot(delta)
	
	# Update position periodically
	time_since_position_update += delta
	if time_since_position_update >= POSITION_UPDATE_INTERVAL:
		time_since_position_update = 0
		_update_position_to_server()
	
	if time_since_damage >= DAMAGE_INTERVAL:
		time_since_damage = 0
		if takes_damage:
			health-=damage_taken_amount
			queue_redraw()
			if health <=0:
				player_dead.emit()
				print("player is dead")
	time_since_damage += delta
	

func shoot(delta:float)-> void:
	
	if Input.is_action_pressed("shoot") and can_shoot:
		speed = MIN_SPEED
		can_shoot = false
		$ShootTimer.start()
		var projectile_start = $ShootingPoints/ShootingPoint
		var direction = (get_global_mouse_position() - position).normalized()
		player_shoot.emit(projectile_start.global_position, direction)
	if Input.is_action_just_released("shoot"):
		speed = MAX_SPEED

func _on_shoot_timer_timeout() -> void:
	can_shoot = true # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	takes_damage = true
	var enemy = area.get_parent()
	if enemy.is_in_group("enemies"):
		var damage = enemy.damage
		damage_taken_amount += damage
		takes_damage = true
	if area.is_in_group("enemy_projectiles"):
		health -= projectile_damage
		area.queue_free()

func _on_area_2d_area_exited(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.is_in_group("enemies"):
		var damage = enemy.damage
		damage_taken_amount -= damage
		takes_damage = false


func handle_direction():
	var animation = $AnimatedSprite2D
	var shooting_point = $ShootingPoints/ShootingPoint
	var direction = (get_local_mouse_position()).normalized()

	if direction.x < 0 and ((direction.y > 0 and direction.y < 0.33) or ((direction.y < 0 and direction.y > -0.33))):
		if normal != Vector2.ZERO:
			animation.play("WalkLeft")
		else:
			animation.play("Left")
		shooting_point.position.x = -175
		shooting_point.position.y = -70
	elif direction.x < 0 and direction.y < -0.33 and direction.y > -0.66:
		if normal != Vector2.ZERO:
			animation.play("WalkUpLeft")
		else:
			animation.play("UpLeft")
		shooting_point.position.x = -175
		shooting_point.position.y = -70
	elif direction.y < 0 and ((direction.x > 0 and direction.x < 0.66) or ((direction.x < 0 and direction.x > -0.66))):
		if normal != Vector2.ZERO:
			animation.play("WalkUp")
		else:
			animation.play("Up")
		shooting_point.position.x = -119
		shooting_point.position.y = -117
	elif direction.x > 0 and direction.y < -0.33 and direction.y > -0.66:
		if normal != Vector2.ZERO:
			animation.play("WalkUpRight")
		else:
			animation.play("UpRight")
		shooting_point.position.x = -175
		shooting_point.position.y = -70
	elif direction.x > 0 and ((direction.y > 0 and direction.y < 0.33) or ((direction.y < 0 and direction.y > -0.66))):
		if normal!=Vector2.ZERO:
			animation.play("WalkRight")
		else:
			animation.play("Right")
		shooting_point.position.x = -64
		shooting_point.position.y = -68
	elif direction.y > 0 and ((direction.x > 0 and direction.x < 0.66) or ((direction.x < 0 and direction.x > -0.66))):
		if normal != Vector2.ZERO:
			animation.play("WalkDown")
		else:
			animation.play("Down")
		shooting_point.position.x = -116
		shooting_point.position.y = -95

func _update_position_to_server() -> void:
	if multiplayer.multiplayer_peer != null:
		var player_data = {
			"position": position,
			"rotation": rotation
		}
		$"/root/MultiplayerManager".update_player_state.rpc(player_data)
func _draw():
	var health := health as int
	var max_health = MAX_HEALTH
	var BAR_WIDTH = 100
	var BAR_HEIGHT = 12
	var BAR_OFFSET = Vector2(0, -128)

	draw_rect(
		Rect2(-BAR_WIDTH/2 + BAR_OFFSET.x, BAR_OFFSET.y,
			  BAR_WIDTH, BAR_HEIGHT),
		Color(0, 0, 0, 0.5)
	)
	var ratio = float(health) / float(max_health)
	draw_rect(
		Rect2(-BAR_WIDTH/2 + BAR_OFFSET.x, BAR_OFFSET.y,
			  BAR_WIDTH * ratio, BAR_HEIGHT),
		Color(1, 0, 0)
	)
