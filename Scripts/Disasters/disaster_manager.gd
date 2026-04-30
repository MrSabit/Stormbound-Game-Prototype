class_name DisasterManager
extends Node

@export var wind_direction: Vector3 = Vector3(0, 0, 0)
@export var wind_strength: float = 10
@export var disasters: Dictionary[Data.Disaster, Area3D]
@export var wind_turn_speed : float = 0.3
var wind_angle: float = 0.0

var disaster_running: bool = false
var target_direction: Vector3 = Vector3(1,0,0)
var current_disasters: Array[Data.Disaster]: 
	set(value):
		current_disasters = value
		if current_disasters:
			disaster_running = true
			$"../Timers/WindTimer".start()
		else:
			disaster_running = false
			EventBus.disaster_ended.emit()
var body_raycasts: Dictionary = {}  # Store one raycast per body

func _process(delta):

	# Occasionally pick new direction
	if randf() < 0.001:
		var angle = randf() * 2 * PI
		target_direction = Vector3(
			cos(angle),
			0,
			sin(angle)
		)
		EventBus.wind_direction_changed.emit(target_direction)
	# Smoothly move toward target
	wind_direction = wind_direction.lerp(
		target_direction,
		delta * 0.5
	)
	
	for key in body_raycasts.keys():

		var ray = body_raycasts[key]

		if not is_instance_valid(ray):
			body_raycasts.erase(key)
			continue

		ray.target_position = wind_direction.normalized() * 10
func _physics_process(delta):
	wind(delta)

func _on_ready_button_pressed() -> void:
	current_disasters.append(Data.Disaster.WIND)
	current_disasters = current_disasters
	setup_raycasts()  # Create raycasts ONCE when wind starts

func setup_raycasts():
	var bodies = disasters[Data.Disaster.WIND].get_overlapping_bodies()
	for body in bodies:
		if body is RigidBody3D:
			var ray = RayCast3D.new()
			ray.enabled = true
			ray.target_position = -wind_direction.normalized() * 10
			ray.collision_mask = 4
			body.add_child(ray)
			body_raycasts[body] = ray  # Store reference

func wind(delta):
	if not current_disasters.has(Data.Disaster.WIND):
		return

	var force = wind_direction.normalized() * wind_strength
	for body in body_raycasts.keys():
		if body and body is RigidBody3D:
			if not is_protected(body):
				body.apply_central_force(force)
				body.health -= delta * 20
	
func is_protected(body: RigidBody3D) -> bool:
	if not body_raycasts.has(body):
		return false
	return body_raycasts[body].is_colliding()


func _on_wind_timer_timeout() -> void:
	current_disasters.erase(Data.Disaster.WIND)
	current_disasters = current_disasters
