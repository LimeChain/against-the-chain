extends TileMapLayer

func _ready() -> void:
	# Paint a 50×30 region at (0,0) with the tile at atlas coords (2,1):
	paint_region(Vector2i(0, 0), Vector2i(50, 30), 0, Vector2i(2, 1), 0)

func paint_region(
		top_left: Vector2i,
		size:    Vector2i,
		source_id:      int,
		atlas_coords:   Vector2i,
		alternative_id: int
	) -> void:
	for x in range(top_left.x, top_left.x + size.x):
		for y in range(top_left.y, top_left.y + size.y):
			set_cell(Vector2i(x, y),
					 source_id,
					 atlas_coords,
					 alternative_id)
	update_internals()
