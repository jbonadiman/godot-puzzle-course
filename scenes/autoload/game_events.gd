extends Node

signal building_placed(component: BuildingComponent)


func emit_building_placed(component: BuildingComponent) -> void:
	if not component:
		push_error("building component doesn't exist!")
	
	building_placed.emit(component)
