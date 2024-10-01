extends Node

@onready var cursor := %Cursor as Sprite2D
@onready var place_building_button := %PlaceBuildingButton as Button
@onready var grid_manager := %GridManager as GridManager

var building_scene := preload("res://scenes/building/building.tscn")
var hovered_grid_cell := Vector2i.MIN


func _ready() -> void:
	place_building_button.pressed.connect(_on_button_pressed)

	cursor.visible = false


func _process(_delta: float) -> void:
	var current_grid_cell := grid_manager.get_mouse_grid_cell_position()

	cursor.global_position = current_grid_cell * 64.0

	if cursor.visible and \
		(not _is_hovering_cell() or hovered_grid_cell != current_grid_cell):

		hovered_grid_cell = current_grid_cell
		grid_manager.highlight_valid_tiles_in_radius(hovered_grid_cell, 3)


func _unhandled_input(event: InputEvent) -> void:
	if _is_hovering_cell() \
	and event.is_action_pressed("left_click") \
	and grid_manager.is_tile_position_valid(hovered_grid_cell):
		_place_building_at_hovered_cell_position()
		cursor.visible = false


func _on_button_pressed() -> void:
	cursor.visible = true


func _is_hovering_cell() -> bool:
	return hovered_grid_cell != Vector2i.MIN


func _place_building_at_hovered_cell_position() -> void:
	if not _is_hovering_cell():
		push_warning("not hovering cell")
		return

	var building := building_scene.instantiate() as Node2D
	add_child(building)

	building.global_position = hovered_grid_cell * 64.0
	grid_manager.mark_tile_as_occupied(hovered_grid_cell)

	hovered_grid_cell = Vector2i.MIN
	grid_manager.clear_highlighted_tiles()
