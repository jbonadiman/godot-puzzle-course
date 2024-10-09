extends Node

@onready var cursor: Sprite2D = %Cursor
@onready var place_tower_button: Button = %PlaceTowerButton
@onready var place_village_button: Button = %PlaceVillageButton
@onready var grid_manager: GridManager = %GridManager
@onready var y_sort_root: Node2D = %YSortRoot

var tower_resource: BuildingResource = \
	preload("res://resources/building/tower.tres")

var village_resource: BuildingResource = \
	preload("res://resources/building/village.tres")

var hovered_grid_cell := Vector2i.MIN
var to_be_placed_resource: BuildingResource

func _ready() -> void:
	place_tower_button.pressed.connect(_on_place_tower_button_pressed)
	place_village_button.pressed.connect(_on_place_village_button_pressed)

	cursor.visible = false


func _process(_delta: float) -> void:
	var current_grid_cell := grid_manager.get_mouse_tile_position()

	cursor.global_position = current_grid_cell * 64.0

	if to_be_placed_resource and \
		cursor.visible and \
		(not _is_hovering_tile() or hovered_grid_cell != current_grid_cell):

		hovered_grid_cell = current_grid_cell
		grid_manager.clear_highlighted_tiles()

		grid_manager.highlight_expanded_buildable_tiles(
			hovered_grid_cell,
			to_be_placed_resource.buildable_radius)

		grid_manager.highlight_resource_tiles(
			hovered_grid_cell,
			to_be_placed_resource.resource_radius)


func _unhandled_input(event: InputEvent) -> void:
	if _is_hovering_tile() \
	and event.is_action_pressed("left_click") \
	and grid_manager.is_tile_position_buildable(hovered_grid_cell):
		_place_building_at_hovered_tile_position()
		cursor.visible = false


func _on_place_tower_button_pressed() -> void:
	to_be_placed_resource = tower_resource
	cursor.visible = true
	grid_manager.highlight_buildable_tiles()


func _on_place_village_button_pressed() -> void:
	to_be_placed_resource = village_resource
	cursor.visible = true
	grid_manager.highlight_buildable_tiles()


func _is_hovering_tile() -> bool:
	return hovered_grid_cell != Vector2i.MIN


func _place_building_at_hovered_tile_position() -> void:
	if not _is_hovering_tile():
		push_warning("not hovering a tile")
		return

	var building: Node2D = to_be_placed_resource.building_scene.instantiate()
	y_sort_root.add_child(building)

	building.global_position = hovered_grid_cell * 64.0

	hovered_grid_cell = Vector2i.MIN
	grid_manager.clear_highlighted_tiles()
