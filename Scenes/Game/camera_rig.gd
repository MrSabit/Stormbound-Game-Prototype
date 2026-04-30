extends Node3D

########################
# SIGNALS
########################
signal freeze_requested
signal jump_requested(location: Vector3, duration: float)
signal camera_moved(new_location: Vector3)

########################
# EXPORT PARAMS
########################

# movement
@export var movement_speed: float = 20.0

# zoom
@export var min_zoom: float = 3.0
@export var max_zoom: float = 20.0
@export var zoom_speed: float = 20.0
@export var zoom_speed_damp: float = 0.8

# rotation
@export var min_elevation_angle: int = 10
@export var max_elevation_angle: int = 80
@export var rotation_speed: float = 20.0

# pan
@export var pan_speed: float = 2.0

# flags
@export var allow_wasd_movement: bool = true
@export var allow_zoom: bool = true
@export var zoom_to_cursor: bool = true
@export var allow_rotation: bool = true
@export var inverted_y: bool = false
@export var allow_pan: bool = true


########################
# PARAMS
########################

var _lock_movement: bool = false

# zoom
@onready var camera: Camera3D = $Elevation/Camera3D
var zoom_direction: float = 0.0

# rotation
@onready var elevation: Node3D = $Elevation
var is_rotating: bool = false

# pan
var is_panning: bool = false

# click position
const RAY_LENGTH := 1000.0
const GROUND_PLANE := Plane(Vector3.UP, 0)

var _last_mouse_position: Vector2


########################
# OVERRIDE FUNCTIONS
########################

func _ready() -> void:
	connect("freeze_requested", _freeze_camera)
	connect("jump_requested", _jump_to_position)


func _process(delta: float) -> void:

	if _lock_movement:
		return

	_move(delta)
	_rotate_and_elevate(delta)
	_zoom(delta)
	_pan(delta)


func _input(event: InputEvent) -> void:

	# Zoom
	if event.is_action_pressed("MouseWheelUp"):
		zoom_direction = -1

	if event.is_action_pressed("MouseWheelDown"):
		zoom_direction = 1

	# Rotation
	if event.is_action_pressed("RightClick"):
		is_rotating = true
		_last_mouse_position = get_viewport().get_mouse_position()

	if event.is_action_released("RightClick"):
		is_rotating = false

	# Pan
	if event.is_action_pressed("MiddleMouse"):
		is_panning = true
		_last_mouse_position = get_viewport().get_mouse_position()

	if event.is_action_released("MiddleMouse"):
		is_panning = false


##############################
# MOVEMENT FUNCTIONS
##############################

func _move(delta: float) -> void:

	if not allow_wasd_movement:
		return

	var velocity := _get_desired_velocity() * delta * movement_speed

	_translate_position(velocity)


func _rotate_and_elevate(delta: float) -> void:

	if not allow_rotation or not is_rotating:
		return

	var mouse_speed := _get_mouse_speed()

	_rotate(mouse_speed.x, delta)
	_elevate(mouse_speed.y, delta)


func _rotate(amount: float, delta: float) -> void:

	rotation_degrees.y += (
		rotation_speed
		* amount
		* delta
	)


func _elevate(amount: float, delta: float) -> void:

	var new_elevation := elevation.rotation_degrees.x

	if inverted_y:
		new_elevation += rotation_speed * amount * delta
	else:
		new_elevation -= rotation_speed * amount * delta

	elevation.rotation_degrees.x = clamp(
		new_elevation,
		-max_elevation_angle,
		-min_elevation_angle
	)


func _zoom(delta: float) -> void:

	if not allow_zoom or zoom_direction == 0:
		return

	var new_zoom = clamp(
		camera.position.z
		+ zoom_direction * zoom_speed * delta,
		min_zoom,
		max_zoom
	)

	var pointing_at = _get_ground_position()

	camera.position.z = new_zoom

	if zoom_to_cursor and pointing_at != null:
		_realign_camera(pointing_at)

	zoom_direction *= zoom_speed_damp

	if abs(zoom_direction) < 0.0001:
		zoom_direction = 0


func _pan(delta: float) -> void:

	if not allow_pan or not is_panning:
		return

	var mouse_speed := _get_mouse_speed()

	var velocity := (global_transform.basis.z * mouse_speed.y + global_transform.basis.x * mouse_speed.x) * delta * pan_speed

	_translate_position(-velocity)


func _jump_to_position(location: Vector3, duration: float) -> void:

	_lock_movement = true

	location.y = position.y

	var tween := create_tween()

	tween.tween_property(
		self,
		"position",
		location,
		duration
	).set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_OUT)

	tween.finished.connect(_end_jump)


##############################
# HELPERS
##############################

func _end_jump() -> void:
	_lock_movement = false


func _get_mouse_speed() -> Vector2:

	var current_mouse_pos := get_viewport().get_mouse_position()

	var mouse_speed := current_mouse_pos - _last_mouse_position

	_last_mouse_position = current_mouse_pos

	return mouse_speed


func _realign_camera(point: Vector3) -> void:

	var new_position = _get_ground_position()

	if new_position == null:
		return

	_translate_position(
		point - new_position
	)


func _translate_position(v: Vector3) -> void:

	position += v

	emit_signal(
		"camera_moved",
		position
	)


func _get_ground_position() -> Variant:

	var mouse_pos := get_viewport().get_mouse_position()

	var ray_from := camera.project_ray_origin(mouse_pos)

	var ray_to := ray_from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH

	return GROUND_PLANE.intersects_ray(
		ray_from,
		ray_to
	)


func _get_desired_velocity() -> Vector3:

	var velocity := Vector3.ZERO

	if is_panning:
		return velocity

	if Input.is_action_pressed("Forward"):
		velocity -= global_transform.basis.z

	if Input.is_action_pressed("Backword"):
		velocity += global_transform.basis.z

	if Input.is_action_pressed("Left"):
		velocity -= global_transform.basis.x

	if Input.is_action_pressed("Right"):
		velocity += global_transform.basis.x

	return velocity.normalized()


func _freeze_camera() -> void:
	_lock_movement = true
