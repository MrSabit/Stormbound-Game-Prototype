class_name ObjectiveManager
extends Node

@onready var objective_label_scene = preload('res://Scenes/UI/objective_label.tscn')
@onready var objective_type_scene = preload('res://Scenes/UI/objective_type.tscn')
@onready var objective_heading_scene = preload('res://Scenes/UI/objective_heading.tscn')
@onready var objective_type_container = objective_hud.get_node('PanelContainer/MarginContainer/ObjectiveTypeContainer')
@export var objective_hud : Control


var objectives : Dictionary[Data.ObjectiveType, Array]
func _ready() -> void:
	EventBus.disaster_ended.connect(_on_disaster_ended)
	
	for obj_type in Data.ObjectiveType.values():
		objectives[obj_type] = []
	
	#Temp Objectives
	objectives[Data.ObjectiveType.MUST_DO] = [
		create_objective(
			Data.ObjectiveType.MUST_DO, 
			Data.ObjectiveRole.SAVE_BUILDING,
			'Save Town Hall',
			2149297990, # Temporary id for testing
			1
			),
		create_objective(
			Data.ObjectiveType.MUST_DO,
			Data.ObjectiveRole.SAVE_AREA,
			"Save Countryside",
			)
	]
	objectives[Data.ObjectiveType.OPTIONAL] = [
		create_objective(Data.ObjectiveType.OPTIONAL, Data.ObjectiveRole.SAVE_X_BUILDING, 'Save ten Houses'),
	]
	
	display_objective()

func create_objective(type, role, description = '', target_id = -1, target_count = 0) -> Objective:
	var objective_res := Objective.new()
	objective_res.type = type
	objective_res.role = role
	objective_res.description = description
	objective_res.target_id = target_id
	objective_res.target_count = target_count
	return objective_res


func display_objective():
	for type : Data.ObjectiveType in objectives.keys():
		var objs :  Array = objectives[type]
		var obj_type_container = objective_hud.get_node('PanelContainer/MarginContainer/ObjectiveTypeContainer')
		var obj_type_node = objective_type_scene.instantiate()
		var obj_container = obj_type_node.get_node('MarginContainer/ObjectiveContainer')
		
		obj_type_container.add_child(obj_type_node)
		
		for child in obj_container.get_children():
			child.queue_free()
		
		#Heading
		var heading : Label = objective_heading_scene.instantiate()
		heading.text = (Data.objective_type_data[type]['heading'])
		var font_color = Data.objective_type_data[type]['color']
		heading.add_theme_color_override('font_color', font_color)
		
		obj_container.add_child(heading)
		
		#Objectives
		for obj in objs:
			var obj_label : Label = objective_label_scene.instantiate()
			obj_label.text = '• ' + obj.description
			obj_container.add_child(obj_label)

func evaluate_objectives():
	var score_data : Dictionary = {}
	for objs in objectives.values():
		for obj in objs:
			match obj.role:
				Data.ObjectiveRole.SAVE_BUILDING:
					if _evaluate_save_building(obj):
						score_data[obj.role] = 1
	EventBus.show_result.emit(score_data)

func _evaluate_save_building(obj: Objective ):
	for node in get_tree().get_first_node_in_group('Buildings').get_children():
		for building_rig: BuildingRig in node.get_children():

			if building_rig.get_child_count() == 0:
				continue
			var building : Building = building_rig.get_child(0)
			print('hello ,' , building)
			print("OBJ ID : ",obj.target_id)
			print("Town ID : ",building.unique_id)
			if building and building.unique_id == obj.target_id:
				if building.health > 0:
					obj.is_completed = true
					print('completed')
					return true

func _on_disaster_ended():
	evaluate_objectives()
