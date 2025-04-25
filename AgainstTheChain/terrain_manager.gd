extends Node

# Terrain generation settings
const WORLD_SIZE = 8192  # 8k x 8k world
const BLOCK_SIZE = 256   # Size of each terrain block
const NUM_BLOCK_TYPES = 32  # Number of unique block types to generate
const NOISE_SCALE = 0.02  # Adjusted for smaller world
const OCTAVES = 4
const PERSISTENCE = 0.5
const LACUNARITY = 2.0

# Dictionary to store generated block types
var block_types = []
# 2D array to store block IDs for the world
var world_grid = []
var is_terrain_generated = false

func _ready():
	# Generate terrain only if it hasn't been generated yet
	if not is_terrain_generated:
		generate_block_types()
		generate_world_grid()
		is_terrain_generated = true

func generate_block_types():
	# Generate NUM_BLOCK_TYPES unique terrain blocks
	for i in range(NUM_BLOCK_TYPES):
		block_types.append(generate_block_type(i))

func generate_block_type(seed_offset: int) -> ImageTexture:
	# Create a new image for the block
	var image = Image.new()
	image.create(BLOCK_SIZE, BLOCK_SIZE, false, Image.FORMAT_RGBA8)
	image.lock()
	
	# Generate noise
	var noise = OpenSimplexNoise.new()
	noise.seed = randi() + seed_offset  # Different seed for each block type
	noise.octaves = OCTAVES
	noise.persistence = PERSISTENCE
	noise.lacunarity = LACUNARITY
	
	# Fill the block with noise
	for x in range(BLOCK_SIZE):
		for y in range(BLOCK_SIZE):
			var nx = x * NOISE_SCALE
			var ny = y * NOISE_SCALE
			var n = noise.get_noise_2d(nx, ny)
			
			# Convert noise to color
			var color = Color()
			if n > 0.2:  # Grass
				color = Color(0.2, 0.8, 0.2)
			elif n > 0:  # Dirt
				color = Color(0.6, 0.3, 0.1)
			else:  # Water
				color = Color(0.2, 0.4, 0.8)
			
			image.set_pixel(x, y, color)
	
	image.unlock()
	
	# Create texture from image
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	return texture

func generate_world_grid():
	# Calculate grid dimensions
	var grid_size = WORLD_SIZE / BLOCK_SIZE
	
	# Initialize the world grid
	world_grid = []
	world_grid.resize(grid_size)
	
	# Fill the grid with random block IDs
	for x in range(grid_size):
		world_grid[x] = []
		world_grid[x].resize(grid_size)
		for y in range(grid_size):
			world_grid[x][y] = randi() % NUM_BLOCK_TYPES

func get_block_texture(block_x: int, block_y: int) -> ImageTexture:
	# Get the block ID from the grid
	var block_id = world_grid[block_x][block_y]
	# Return the corresponding block texture
	return block_types[block_id]

# Helper function to get block coordinates from world position
func get_block_coords(world_pos: Vector2) -> Vector2:
	return Vector2(
		floor(world_pos.x / BLOCK_SIZE),
		floor(world_pos.y / BLOCK_SIZE)
	) 
