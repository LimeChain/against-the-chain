extends CharacterBody2D

@export var speed        := 200
@export var max_health   := 3
var health               := max_health
@export var damage       := 1
var player

# Health‐bar constants
const BAR_WIDTH  := 100
const BAR_HEIGHT := 12
const BAR_OFFSET := Vector2(0, -128)

signal dead(enemy: CharacterBody2D)

func _ready() -> void:
	$Area2D.area_entered.connect(_on_area_entered)
	player = get_node("/root/World/Player")
	# draw the bar once at start
	queue_redraw()

func _process(delta: float) -> void:
	position += (player.position - position).normalized() * speed * delta

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
		queue_redraw()         # ← schedule a redraw of _draw()
		if health == 0:
			dead.emit(self)
