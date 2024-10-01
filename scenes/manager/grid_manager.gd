extends Node
class_name GridManager

@export var highlight_tilemap: TileMapLayer
@export var base_terrain_tilemap: TileMapLayer

## TODO: supply type in 4.4
var occupied_cells: Dictionary = {}

func is_tile_position_valid(tile_position: Vector2i) -> bool:
	var custom_data := base_terrain_tilemap.get_cell_tile_data(tile_position)
	if not custom_data:
		return false

	if not (custom_data.get_custom_data("buildable") as bool):
		return false

	return not occupied_cells.has(tile_position)


func mark_tile_as_occupied(tile_position: Vector2i) -> void:
	occupied_cells[tile_position] = true


func highlight_valid_tiles_in_radius(root_cell: Vector2i, radius: int) -> void:
	clear_highlighted_tiles()

	for x in range(root_cell.x - radius, root_cell.x + radius + 1):
		for y in range(root_cell.y - radius, root_cell.y + radius + 1):
			var current_cell := Vector2i(x, y)

			if not is_tile_position_valid(current_cell):
				continue

			highlight_tilemap.set_cell(current_cell, 0, Vector2i.ZERO)


func get_mouse_grid_cell_position() -> Vector2i:
	return Vector2i((highlight_tilemap.get_global_mouse_position() / 64).floor())


func clear_highlighted_tiles() -> void:
	highlight_tilemap.clear()
