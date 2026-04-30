@tool
class_name BuildingRig
extends Node3D

@export var building_scenes : Dictionary[Data.BuildingType , PackedScene]
@export var building_type : Data.BuildingType : 
	set(value):
		building_type = value
		call_deferred("_update_building", value)


func _update_building(type: Data.BuildingType):
	if building_scenes.has(type):
		
		for child in get_children():
			child.free()
		
		var building : Building = building_scenes[type].instantiate()
		add_child(building)
		building.unique_id = hash(str(self.get_path()))
		building.owner = self
