extends CanvasGroup

#@onready var texture_rect = $TextureRect
#var viewport
#func _ready():
	#texture_rect.texture = preload("res://assets/loading.png")
	#texture_rect.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_COVERED
	#texture_rect.set_begin(Vector2.ZERO)
	## Get the screen size using DisplayServer
	#
#
func _process(delta:float):
	var screen_size = DisplayServer.window_get_size()
	$TextureRect.set_size(screen_size)
	$TextureRect.scale = Vector2(1.2,1.2)
	#$TextureRect.position.x -= 2
	#$TextureRect.position.y -= 2
	#var viewport_position = viewport.get_viewport_position()
	#print(screen_size)
	# Set the size of the TextureRect to match the screen size
	
