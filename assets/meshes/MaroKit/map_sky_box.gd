extends Node3D

@export var rotation_speed: float = 18.0  # Degrees per second

func _process(delta):
	rotation_degrees.y += rotation_speed * delta  # Rotate on Y-axis (for 3D)
	
	# If rotation reaches or exceeds 360 degrees, reset to 0
	if rotation_degrees.y >= 360:
		rotation_degrees.y = 0
