extends Node

enum Item {WALL, NULL}
enum Disaster {WIND}
enum BuildingType {TOWN_HALL, HOUSE}
enum ObjectiveRole {SAVE_BUILDING, SAVE_AREA, SAVE_X_BUILDING}
enum ObjectiveType {MUST_DO, OPTIONAL, CHALLENGE}

var available_items = [
	Item.WALL, 
	Item.NULL
]

var selected_item : Item = Item.NULL
var total_building : int
var building_addition : int
var building_deletion : int
var item_icons = {
	Item.WALL : preload('res://Graphics/UI/wall_icon.png'),
	Item.NULL : preload('res://Graphics/UI/null_slot_texture.png')
}
var tree
var inventory := {
	2 : [Item.WALL , 7]
}

var max_inventory_slot : int = 8

var objective_type_data := {
	Data.ObjectiveType.MUST_DO : 
		{
			'color' : Color(0.0, 0.82, 0.137, 1.0),
			'heading' : "Must Do",
		},
	Data.ObjectiveType.OPTIONAL : 
		{
			'color' : Color(0.909, 1.0, 0.327, 1.0),
			'heading' : "Optional",
		},
	Data.ObjectiveType.CHALLENGE : 
		{
			'color' : Color(0.579, 0.0, 0.0, 1.0),
			'heading' : "Challenge",
		}
}

func _ready() -> void:
	EventBus.building_added.connect(_on_building_added)
	EventBus.building_removed.connect(_on_building_removed)
	for node  in get_tree().get_first_node_in_group('Buildings').get_children():
		for child in node.get_children():
			building_addition += 1
			total_building += 1
func _on_building_added():
	total_building += 1
	building_addition += 1
func _on_building_removed():
	total_building -= 1
	building_deletion += 1
