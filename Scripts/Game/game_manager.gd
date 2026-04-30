extends Node

@onready var houses := $"../Village/Buildings/Houses"
var total_building_count : int
var is_paused : bool
var destroyed_building_count : int

func _ready() -> void:
	Data.tree = get_tree()
	EventBus.building_distoryed.connect(_on_building_destoryed)
	
	for house in houses.get_children():
		total_building_count += 1
	total_building_count += 1

func _calculate_score_data():
	pass
	#for objective_rol
	
	
	
	#var saved_building_count := total_building_count - destroyed_building_count 
	#var score_data := {}
	#score_data[Data.ObjectiveRole.SAVE_X_BUILDING] = saved_building_count
	#return score_data

func _on_building_destoryed():
	destroyed_building_count += 1

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
