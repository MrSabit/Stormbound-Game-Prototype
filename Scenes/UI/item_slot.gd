class_name ItemSlot
extends TextureButton

@onready var ui = get_tree().get_first_node_in_group('UI')

var slot_id : int
var slot_item = -1
var slot_item_count : int : 
	set(value):
		slot_item_count = clamp(value, 0, Data.max_inventory_slot)
		if slot_item_count:
			$MarginContainer/ItemCount.text = str(slot_item_count)
			$MarginContainer/ItemCount.show()
		else:
			$MarginContainer/ItemCount.hide()
var item_texture : CompressedTexture2D : 
	set(value) :
		print(slot_item_count)
		if slot_item_count > 0:
			item_texture = value
			$IconContainer/ItemIcon.texture = item_texture
		else:
			$IconContainer/ItemIcon.texture = null
func _ready() -> void:
	EventBus.update_hotbar.connect(_on_update_hotbar)

func _on_pressed() -> void:
	if slot_item != -1:
		Data.selected_item = slot_item as Data.Item
	else:
		Data.selected_item = Data.Item.NULL
	grab_focus()

func _on_update_hotbar():
	if Data.inventory.has(slot_id):
		var inventory_item_data = Data.inventory[slot_id]
		slot_item = inventory_item_data[0]
		slot_item_count = inventory_item_data[1]
		item_texture = Data.item_icons[inventory_item_data[0]]
