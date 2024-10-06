extends Node
class_name GridManager

@export var highlight_tile_map: TileMapLayer
@export var base_terrain_tile_map: TileMapLayer

## TODO: supply type in 4.4
## var valid_buildable_tiles: Dictionary[Vector2i, bool] = {}
var valid_buildable_tiles: Dictionary = {}
var all_tile_map_layers: Array[TileMapLayer] = []

func _ready() -> void:
	GameEvents.building_placed.connect(_on_building_placed)
	assert(base_terrain_tile_map, "'base_terrain_tile_map' not defined in the editor!")
	assert(highlight_tile_map, "'highlight_tile_map' not defined in the editor!")
	
	all_tile_map_layers = _get_all_tile_map_layers(base_terrain_tile_map)
	
	for layer in all_tile_map_layers:
		print(layer.name)


func is_tile_position_valid(tile_position: Vector2i) -> bool:
	var custom_data: TileData
	for layer: TileMapLayer in all_tile_map_layers:
		custom_data = layer.get_cell_tile_data(tile_position)
		if not custom_data:
			continue
		return custom_data.get_custom_data("buildable") as bool
	
	return false

func is_tile_position_buildable(tile_position: Vector2i) -> bool:
	return valid_buildable_tiles.has(tile_position)


func highlight_buildable_tiles() -> void:
	for tile_position in valid_buildable_tiles:
		highlight_tile_map.set_cell(tile_position, 0, Vector2i.ZERO)


func highlight_expanded_buildable_tiles(root_cell: Vector2i, radius: int) -> void:
	clear_highlighted_tiles()
	highlight_buildable_tiles()
	
	var valid_tiles := _get_valid_tiles_in_radius(root_cell, radius)
	var occupied_tiles := _get_occupied_tiles()
	
	var expanded_tiles := valid_tiles \
		.filter(
			func(tile: Vector2i): return not valid_buildable_tiles.has(tile)) \
		.filter(
			func(tile: Vector2i): return not occupied_tiles.has(tile))
	
	const ATLAS_COORD := Vector2i(1, 0)
	for tile_position in expanded_tiles:
		highlight_tile_map.set_cell(tile_position, 0, ATLAS_COORD)

 
func get_mouse_tile_position() -> Vector2i:
	return Vector2i(
		(highlight_tile_map.get_global_mouse_position() / 64).floor())


func clear_highlighted_tiles() -> void:
	highlight_tile_map.clear()


func _update_valid_buildable_tiles(component: BuildingComponent) -> void:
	if not component:
		push_error("building component doesn't exist!")
		return
	
	var root_cell := component.get_grid_cell_position()
	
	var valid_tiles := _get_valid_tiles_in_radius(
		root_cell,
		component.buildable_radius)

	for tile: Vector2i in valid_tiles:
		valid_buildable_tiles[tile] = true

	for tile: Vector2i in _get_occupied_tiles():
		valid_buildable_tiles.erase(tile)


func _get_all_tile_map_layers(root_layer: TileMapLayer) -> Array[TileMapLayer]:
	if not root_layer:
		push_error("root layer is null!")
		return []
	
	var result: Array[TileMapLayer]
	var children: Array[Node] = root_layer.get_children()
	children.reverse()
	
	var child_layer: TileMapLayer
	for child: Node in children:
		child_layer = child as TileMapLayer
		if child_layer:
			result.append_array(_get_all_tile_map_layers(child_layer))
	result.push_back(root_layer)
	return result

func _get_occupied_tiles() -> Array[Vector2i]:
	var result: Array[Vector2i]
	result.assign(get_tree() \
		.get_nodes_in_group("building_component") \
		.map(func(n: Node):
			var parsed_node: BuildingComponent = n
			return parsed_node.get_grid_cell_position()))

	return result


func _get_valid_tiles_in_radius(root_cell: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x: int in range(root_cell.x - radius, root_cell.x + radius + 1):
		for y: int in range(root_cell.y - radius, root_cell.y + radius + 1):
			var current_cell := Vector2i(x, y)

			if not is_tile_position_valid(current_cell):
				continue

			result.push_back(current_cell)
	return result


func _on_building_placed(component: BuildingComponent) -> void:
	if not component:
		push_error("building component doesn't exist!")
		return
	_update_valid_buildable_tiles(component)
