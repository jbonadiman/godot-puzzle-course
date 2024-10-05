extends Node
class_name GridManager

@export var highlight_tilemap: TileMapLayer
@export var base_terrain_tilemap: TileMapLayer

## TODO: supply type in 4.4
## var valid_buildable_tiles: Dictionary[Vector2i, bool] = {}
var valid_buildable_tiles: Dictionary = {}


func _ready() -> void:
	GameEvents.building_placed.connect(_on_building_placed)


func is_tile_position_valid(tile_position: Vector2i) -> bool:
	var custom_data := base_terrain_tilemap.get_cell_tile_data(tile_position)
	if not custom_data:
		return false

	return custom_data.get_custom_data("buildable") as bool


func is_tile_position_buildable(tile_position: Vector2i) -> bool:
	return valid_buildable_tiles.has(tile_position)


func highlight_buildable_tiles() -> void:
	for tile_position in valid_buildable_tiles:
		highlight_tilemap.set_cell(tile_position, 0, Vector2i.ZERO)


func get_mouse_grid_cell_position() -> Vector2i:
	return Vector2i((highlight_tilemap.get_global_mouse_position() / 64).floor())


func clear_highlighted_tiles() -> void:
	highlight_tilemap.clear()


func _update_valid_buildable_tiles(component: BuildingComponent) -> void:
	if not component:
		push_error("building component doesn't exist!")
		return
	
	var root_cell := component.get_grid_cell_position()
	var radius := component.buildable_radius

	for x in range(root_cell.x - radius, root_cell.x + radius + 1):
		for y in range(root_cell.y - radius, root_cell.y + radius + 1):
			var current_cell := Vector2i(x, y)

			if not is_tile_position_valid(current_cell):
				continue

			valid_buildable_tiles[current_cell] = true
	valid_buildable_tiles.erase(root_cell)

func _on_building_placed(component: BuildingComponent) -> void:
	if not component:
		push_error("building component doesn't exist!")
		return
	_update_valid_buildable_tiles(component)
