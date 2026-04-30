extends Control

@onready var item_container := $HotBox/MarginContainer/ItemContainer
@onready var item_slot_scene : PackedScene = preload('res://Scenes/UI/item_slot.tscn')
@onready var objective_hud := %ObjectiveHUD
var item_slots : Array[ItemSlot]

func setup_hotbar():
	for item in Data.max_inventory_slot:
		if not item_slot_scene:
			item_slot_scene = load('res://Scenes/UI/item_slot.tscn')
		var item_slot = item_slot_scene.instantiate()
		if not item_container:
			item_container =  $HotBox/MarginContainer/ItemContainer
		item_container.add_child(item_slot)
		item_slots.append(item_slot)

func _process(_delta: float) -> void:
	$FPS/Label.text = "FPS: " + str(Engine.get_frames_per_second())

func update_item_slot(slot_id : int, slot_data : Dictionary):
	var slot = item_slots[slot_id]
	
	slot.slot_item_count = slot_data['item count']
	slot.slot_id = slot_id
	slot.slot_item = slot_data['item']
	slot.item_texture = slot_data['texture']


func _on_button_pressed() -> void:
	if objective_hud.is_visible_in_tree():
		%ShowHideButton.text = ' > '
		hide_objective_panel()
	else:
		%ShowHideButton.text = ' < '
		reveal_objective_panel()


func reveal_objective_panel():
	objective_hud.show()
	var tween = create_tween()
	tween.tween_method(_set_margine_left_for_objective, -197, 0, 0.3)
func hide_objective_panel():
	var tween = create_tween()
	tween.tween_method(_set_margine_left_for_objective, 0, -197, 0.3)
	await tween.finished
	objective_hud.hide()


func _set_margine_left_for_objective(value):
	%ObjectiveMargine.add_theme_constant_override("margin_left", value)
