extends Node

# Terrain generation settings
const WORLD_SIZE = 8192  # 8k x 8k world
const CHUNK_SIZE = 256   # Size of each terrain chunk (32x32 chunks total)
const NOISE_SCALE = 0.02  # Adjusted for smaller world
const OCTAVES = 4
const PERSISTENCE = 0.5
const LACUNARITY = 2.0

# Dictionary to store generated chunks
var generated_chunks = {}

func generate_all_chunks():
	# Calculate number of chunks needed
	var chunks_per_side = WORLD_SIZE / CHUNK_SIZE
	
	# Generate all chunks
	for x in range(chunks_per_side):
		for y in range(chunks_per_side):
			generate_chunk(x, y)

func generate_chunk(chunk_x: int, chunk_y: int) -> ImageTexture:
	# Check if we already generated this chunk
	var chunk_key = str(chunk_x) + "," + str(chunk_y)
	if generated_chunks.has(chunk_key):
		return generated_chunks[chunk_key]
	
	# Create a new image for the chunk
	var image = Image.new()
	image.create(CHUNK_SIZE, CHUNK_SIZE, false, Image.FORMAT_RGBA8)
	image.lock()
	
	# Generate noise
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = OCTAVES
	noise.persistence = PERSISTENCE
	noise.lacunarity = LACUNARITY
	
	# Fill the chunk with noise
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			# Calculate world position for noise sampling
			var world_x = (chunk_x * CHUNK_SIZE) + x
			var world_y = (chunk_y * CHUNK_SIZE) + y
			var nx = world_x * NOISE_SCALE
			var ny = world_y * NOISE_SCALE
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
	
	# Store the generated chunk
	generated_chunks[chunk_key] = texture
	
	return texture

# Helper function to get chunk coordinates from world position
func get_chunk_coords(world_pos: Vector2) -> Vector2:
	return Vector2(
		floor(world_pos.x / CHUNK_SIZE),
		floor(world_pos.y / CHUNK_SIZE)
	) 