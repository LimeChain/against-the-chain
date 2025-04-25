extends Node2D

# Preload the zombie scene
const ZombieScene = preload("res://zombie.tscn")

var player = null
var camera = null

# Terrain settings
const WORLD_SIZE = 8192
const BLOCK_SIZE = 256
const LOAD_DISTANCE = 4  # How many blocks to load in each direction from the player

# Camera zoom settings
const MIN_ZOOM = 0.5
const MAX_ZOOM = 2.0
const ZOOM_SPEED = 0.1

# Dictionary to store loaded terrain sprites
var loaded_blocks = {}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the player reference
	player = get_node("Player")
	# Set random player position
	player.position = Vector2(
		rand_range(0, WORLD_SIZE),
		rand_range(0, WORLD_SIZE)
	)
	
	# Create and setup camera
	setup_camera()
	
	# Connect to the zombie_died signal from all zombies
	for zombie in get_tree().get_nodes_in_group("zombies"):
		zombie.connect("zombie_died", self, "_on_zombie_died")
		zombie.set_player(player)
		# Set random position for existing zombies
		zombie.position = Vector2(
			rand_range(0, WORLD_SIZE),
			rand_range(0, WORLD_SIZE)
		)
	
	# Initial terrain load
	update_terrain()

func setup_camera():
	# Create a new camera
	camera = Camera2D.new()
	# Make it current
	camera.current = true
	# Add it as a child of the player
	player.add_child(camera)
	# Position it at the player's center
	camera.position = Vector2.ZERO
	# Set camera limits to world bounds
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = WORLD_SIZE
	camera.limit_bottom = WORLD_SIZE

func _process(_delta):
	update_terrain()

func update_terrain():
	var player_block = TerrainManager.get_block_coords(player.global_position)
	
	# Unload blocks that are too far away
	for block_key in loaded_blocks.keys():
		var block_pos = Vector2(
			float(block_key.split(",")[0]),
			float(block_key.split(",")[1])
		)
		if abs(block_pos.x - player_block.x) > LOAD_DISTANCE or \
		   abs(block_pos.y - player_block.y) > LOAD_DISTANCE:
			loaded_blocks[block_key].queue_free()
			loaded_blocks.erase(block_key)
	
	# Load new blocks
	for x in range(player_block.x - LOAD_DISTANCE, player_block.x + LOAD_DISTANCE + 1):
		for y in range(player_block.y - LOAD_DISTANCE, player_block.y + LOAD_DISTANCE + 1):
			# Check if block is within world bounds
			if x >= 0 and x < WORLD_SIZE/BLOCK_SIZE and \
			   y >= 0 and y < WORLD_SIZE/BLOCK_SIZE:
				var block_key = str(x) + "," + str(y)
				if not loaded_blocks.has(block_key):
					# Create new terrain sprite
					var terrain = Sprite.new()
					terrain.texture = TerrainManager.get_block_texture(x, y)
					terrain.position = Vector2(x * BLOCK_SIZE, y * BLOCK_SIZE)
					add_child(terrain)
					# Move terrain behind other objects
					terrain.z_index = -1
					loaded_blocks[block_key] = terrain

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			# Zoom in
			camera.zoom = Vector2(
				max(camera.zoom.x - ZOOM_SPEED, MIN_ZOOM),
				max(camera.zoom.y - ZOOM_SPEED, MIN_ZOOM)
			)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			# Zoom out
			camera.zoom = Vector2(
				min(camera.zoom.x + ZOOM_SPEED, MAX_ZOOM),
				min(camera.zoom.y + ZOOM_SPEED, MAX_ZOOM)
			)

# Function to spawn a new zombie
func spawn_zombie():
	var zombie = ZombieScene.instance()
	add_child(zombie)
	# Connect the new zombie's signal
	zombie.connect("zombie_died", self, "_on_zombie_died")
	# Add to zombies group
	zombie.add_to_group("zombies")
	# Set the player reference
	zombie.set_player(player)
	# Set random position within the game world
	zombie.position = Vector2(
		rand_range(0, WORLD_SIZE),
		rand_range(0, WORLD_SIZE)
	)

# Called when a zombie dies
func _on_zombie_died():
	spawn_zombie()
