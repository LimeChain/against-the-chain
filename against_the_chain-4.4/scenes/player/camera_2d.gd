extends Camera2D

var max_width = 10_000
var max_height = 10_000

func _ready():
	# Define the limits for the camera (this restricts the viewable area)
	limit_left = 0
	limit_top = 0
	limit_right = max_width
	limit_bottom = max_height
	
