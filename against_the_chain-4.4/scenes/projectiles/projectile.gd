extends Area2D

var speed = 1200

var direction_to_shoot:Vector2

signal destroy(projectile: Area2D)
func _ready():
	$DestructorTimer.start()
	
func _process(delta: float) -> void:
	position += direction_to_shoot * speed * delta

func _on_destructor_timer_timeout() -> void:
	destroy.emit(self)
