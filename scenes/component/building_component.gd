extends Node2D
class_name BuildingComponent

@export var buildable_radius: int:
	get:
		return buildable_radius


func _ready() -> void:
	add_to_group("building_component")
	GameEvents.emit_building_placed.bind(self).call_deferred()


func get_grid_cell_position() -> Vector2i:
	return Vector2i((global_position / 64).floor())
