extends Node2D

@onready var cursor := %Cursor as Sprite2D
@onready var place_building_button := %PlaceBuildingButton as Button
@onready var highlight_tilemap_layer := %HighlightTileMapLayer as TileMapLayer

var building_scene := preload("res://scenes/building/building.tscn")
var hovered_grid_cell := Vector2.INF


func _ready() -> void:
  place_building_button.pressed.connect(_on_button_pressed)

  cursor.visible = false


func _process(_delta: float) -> void:
  var current_grid_cell := _get_mouse_grid_cell_position()

  cursor.global_position = current_grid_cell * 64

  if cursor.visible and \
      (not _is_hovering_cell() or hovered_grid_cell != current_grid_cell):

    hovered_grid_cell = current_grid_cell
    _update_highlight_tilemap_layer()


func _unhandled_input(event: InputEvent) -> void:
  if cursor.visible and event.is_action_pressed("left_click"):
    _place_building_at_mouse_position()
    cursor.visible = false


func _on_button_pressed() -> void:
  cursor.visible = true


func _is_hovering_cell() -> bool:
  return hovered_grid_cell != Vector2.INF


func _update_highlight_tilemap_layer() -> void:
  highlight_tilemap_layer.clear()

  if not _is_hovering_cell():
    return

  for x in range(hovered_grid_cell.x - 3, hovered_grid_cell.x + 4):
    for y in range(hovered_grid_cell.y - 3, hovered_grid_cell.y + 4):
      highlight_tilemap_layer.set_cell(Vector2i(x, y), 0, Vector2i.ZERO)


func _get_mouse_grid_cell_position() -> Vector2:
  return (get_global_mouse_position() / 64).floor()


func _place_building_at_mouse_position() -> void:
  var building := building_scene.instantiate() as Node2D
  add_child(building)

  building.global_position = _get_mouse_grid_cell_position() * 64

  hovered_grid_cell = Vector2.INF
  _update_highlight_tilemap_layer()
