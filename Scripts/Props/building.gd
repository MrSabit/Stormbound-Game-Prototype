class_name Building
extends RigidBody3D

@export var type: Data.BuildingType

@export var unique_id : int

var health : float = 100:
	set(value):
		health = value
		if health <= 0:
			EventBus.building_distoryed.emit()
			queue_free()
