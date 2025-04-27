extends CharacterBody2D

var projectile_scene = preload("res://scenes/projectiles/projectile.tscn")

@export var speed        := 200
@export var max_health   := 3
var health               := max_health
@export var damage       := 1
var player
var can_shoot := true
var sprite_direction:Vector2

# Health‐bar constants
const BAR_WIDTH  := 100
const BAR_HEIGHT := 12
const BAR_OFFSET := Vector2(0, -128)
signal dead(enemy: CharacterBody2D)
signal shoot (position: Vector2, enemy_pos: Vector2)

func _ready() -> void:
	$Area2D.area_entered.connect(_on_area_entered)
	player = get_node("/root/World/Player")
	# draw the bar once at start
	queue_redraw()
	$ShootTimer.start()

func _process(delta: float) -> void:
	handle_direction(player.position.normalized())
	var enemy_manager = get_parent()
	var direction
	if enemy_manager.is_captain_ritual:
		var captain = enemy_manager.find_captain(enemy_manager.enemies)
		direction = (captain.position-position).normalized()
	else:
		direction = (player.position-position).normalized()
	velocity = direction * speed
	move_and_slide()
	# shoot
	if can_shoot:
		shoot.emit($ShootingPoint.global_position, position)
		can_shoot = false

func _draw() -> void:
	 # background
	draw_rect(
		Rect2(-BAR_WIDTH/2 + BAR_OFFSET.x, BAR_OFFSET.y,
			  BAR_WIDTH, BAR_HEIGHT),
		Color(0, 0, 0, 0.5)
	)
	# filled portion
	var ratio = float(health) / float(max_health)
	draw_rect(
		Rect2(-BAR_WIDTH/2 + BAR_OFFSET.x, BAR_OFFSET.y,
			  BAR_WIDTH * ratio, BAR_HEIGHT),
		Color(1, 0, 0)
	)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectiles"):
		area.destroy.emit(area)
		health = max(health - damage, 0)
		speed/=2
		queue_redraw()      # ← schedule a redraw of _draw()	
		if health == 0:
			speed=0
			$AnimatedSprite2D.animation_looped.connect(func ():
				dead.emit(self)
			)
		
func _on_area_exited(area: Area2D):
	if area.is_in_group("projectiles"):
		speed *= 2

func handle_direction(direction: Vector2):
	var animation = $AnimatedSprite2D
	print("health", health)
	if health > 0 and direction.x < 0:
	#and ((direction.y > 0 and direction.y < 0.5) or ((direction.y < 0 and direction.y > -0.5))):
		sprite_direction = Vector2.LEFT
		animation.play("WalkLeft")
	elif health > 0 and direction.x > 0:
	#and ((direction.y > 0 and direction.y < 0.5) or ((direction.y < 0 and direction.y > -0.5))):
		sprite_direction = Vector2.RIGHT
		animation.play("WalkRight")
	elif health > 0 and direction.y < 0 and ((direction.x > 0 and direction.x < 0.5) or ((direction.x < 0 and direction.x > -0.5))):
		pass
	elif health > 0 and direction.y > 0 and ((direction.x > 0 and direction.x < 0.5) or ((direction.x < 0 and direction.x > -0.5))):
		pass
	elif health <=0 and direction.x > 0:
		animation.play("DestroyRight")
	elif health <=0 and direction.x < 0:
		animation.play("DestroyLeft")


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
	
