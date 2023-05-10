extends Camera2D

@export var camera_speed : float

func _ready():
	position_smoothing_enabled = true
	rotation_smoothing_enabled = true
	position_smoothing_speed = camera_speed
	rotation_smoothing_speed = camera_speed
