extends Control

func _ready() -> void:
	# Set the control to be in the viewport layer
	top_level = true
	
func _process(delta: float) -> void:
	# Get the window size
	var window_size = DisplayServer.window_get_size()
	
	# Set the position to the right side of the window
	position.x = window_size.x - 40  # 40 pixels from the right edge
	
	# Center vertically
	position.y = (window_size.y - size.y) / 2
	
	# Set the height to 80% of the window height
	size.y = window_size.y * 0.8
	size.x = 40  # Width of the bar
