extends Node2D

@export var player_id: int
@export var color: Color = Color(1, 0, 0)  # Default red color

var square: ColorRect

func _ready() -> void:
	# Create a simple square
	square = ColorRect.new()
	square.size = Vector2(20, 20)  # Size of the indicator
	square.color = color
	square.position = Vector2(-10, -10)  # Center the square
	add_child(square)
	
	# Add a label to show the client ID
	var label = Label.new()
	label.text = str(player_id)
	label.position = Vector2(-5, -5)  # Position the label
	label.add_theme_font_size_override("font_size", 12)
	add_child(label)

func update_position(new_position: Vector2) -> void:
	position = new_position 
