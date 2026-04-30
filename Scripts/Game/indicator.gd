extends Node3D

var angle := 0.0
var current_angle: float
func _ready() -> void:
	EventBus.wind_direction_changed.connect(_on_wind_direction_changed)

func _process(delta: float) -> void:

	# Smoothly rotate toward it
	current_angle = lerp_angle(
		current_angle,
		angle,
		delta * 5.0   # rotation speed
	)
	rotation.y = current_angle
func _on_wind_direction_changed(dir : Vector3):
	angle = -atan2(dir.z, dir.x)
