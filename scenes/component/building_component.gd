extends Node2D
class_name BuildingComponent

@export_file("*.tres") var building_resource_path: String

var building_resource: BuildingResource

func _ready() -> void:
	if not building_resource_path.is_empty():
		building_resource = load(building_resource_path)

	add_to_group("building_component")
	GameEvents.emit_building_placed.bind(self).call_deferred()


func get_grid_cell_position() -> Vector2i:
	return Vector2i((global_position / 64).floor())
