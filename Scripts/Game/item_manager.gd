extends Node

@onready var wall_scene : PackedScene = preload("res://Scenes/Props/walls/wall.tscn")
@onready var walls := $"../Village/Walls"
@onready var ui := $"../UI"
@export var selected_items : Node


var wall_instance : StaticBody3D

func _ready() -> void:
	add_wall_instance()
	ui.setup_hotbar()
	setup_inventory()
func _process(_delta: float) -> void:
	match Data.selected_item:
		Data.Item.WALL:
			wall_logic()
		Data.Item.NULL:
			for child in selected_items.get_children():
				child.hide()

func wall_logic():
	var can_place: bool
	for child in selected_items.get_children():
		child.hide()
	
	var wall_area =  wall_instance.get_node("WallArea") as Area3D
	if wall_area and wall_area.get_overlapping_bodies():
		can_place = false
		var wall_mesh = wall_instance.get_node("CSGBox3D") as CSGBox3D
		wall_mesh.material.albedo_color = Color(1.0, 0.304, 0.205, 0.4) 
	else:
		can_place = true
		var wall_mesh = wall_instance.get_node("CSGBox3D") as CSGBox3D
		wall_mesh.material.albedo_color = Color(0.0, 0.607, 0.985, 0.4)
		
	wall_instance.show()
	var mouse_pos = get_mouse_world_position()
	var pos := Vector3.ZERO
	if mouse_pos:
		pos = Vector3(mouse_pos.x, 0 , mouse_pos.z)
		
	wall_instance.global_position = pos
	if Input.is_action_just_pressed('RotoLeft'):
		wall_instance.rotation.y += 15 * PI / 180
		
	if Input.is_action_just_pressed('RotoRight'):
		wall_instance.rotation.y -= 15 * PI / 180
	
	if Input.is_action_just_pressed("LeftClick") and can_place:
		var rotation = wall_instance.global_rotation
		_place_wall(pos, rotation)
	
func get_mouse_world_position():
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()

	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)

	var ray_length = 1000
	var ray_end = ray_origin + ray_direction * ray_length

	var space_state = get_parent().get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, 8)

	var result = space_state.intersect_ray(query)

	if result:
		return result.position

	return null

func _place_wall(pos : Vector3, rotation : Vector3):
	var can_place : bool
	
	for slot in Data.max_inventory_slot:
		if Data.inventory.has(slot):
			if Data.inventory[slot][0] == Data.Item.WALL and Data.inventory[slot][1] > 0:
				can_place = true
				break
			else:
				can_place = false
		else:
			can_place = false
	if not can_place:
		return
	var wall = wall_scene.instantiate()
	walls.add_child(wall)
	wall.global_position = pos
	wall.global_rotation = rotation
	for slot in Data.max_inventory_slot:
		if Data.inventory.has(slot):
			if Data.inventory[slot][0] == Data.Item.WALL:
				update_inventory(Data.Item.WALL , false , 1)

func add_wall_instance():
	wall_instance = wall_scene.instantiate()
	wall_instance.get_node("CollisionShape3D").queue_free()
	
	selected_items.add_child(wall_instance)
	wall_instance.hide()
	var wall_mesh = wall_instance.get_node("CSGBox3D") as CSGBox3D
	wall_mesh.material.albedo_color = Color(0.0, 0.607, 0.985, 0.4) 
	
	var area = Area3D.new()
	area.name = "WallArea"
	
	var coll_shape = CollisionShape3D.new()
	coll_shape.shape = BoxShape3D.new()
	coll_shape.shape.size = Vector3(5, 3, 1)
	
	area.add_child(coll_shape)
	wall_instance.add_child(area)
	
	area.collision_layer = 3
	area.collision_mask = 1 | 2 | 4
	
func setup_inventory():
	for slot in Data.max_inventory_slot:
		if Data.inventory.has(slot):
			var item = Data.inventory[slot]
			var slot_data := {
				'texture' : Data.item_icons[item[0]],
				'item' : item[0],
				'item count' : item[1]
			}
			ui.update_item_slot(slot, slot_data)

func update_inventory(item, is_add , amount):
	for slot in Data.inventory.keys():
		var item_data = Data.inventory[slot]
		if item_data.get(0) == item:
			if is_add:
				item_data[1] += amount
			else:
				item_data[1] -= amount
				if item_data[1] <= 0:
					Data.inventory.erase(slot)
					Data.inventory[slot] = [Data.Item.NULL, 0]
					Data.selected_item = Data.Item.NULL
		elif item_data.get(0) == Data.Item.NULL:
			if is_add:
				Data.inventory[slot] = [item, amount]
		EventBus.update_hotbar.emit()
