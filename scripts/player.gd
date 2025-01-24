extends CharacterBody3D

@export var move_speed: float = 5.0
@export var look_sensitivity: float = 0.002
@export var jump_strength: float = 8.0
@export var gravity: float = -20.0

# Internal variables
var pitch: float = 0.0

# Called every frame
func _process(delta: float) -> void:
	handle_movement(delta)
	handle_look()

# Handle player movement
func handle_movement(delta: float) -> void:
	# Get input direction
	var input_direction: Vector3 = Vector3.ZERO
	input_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")

	# Adjust for camera direction
	input_direction = input_direction.normalized()
	var rotated_direction = (global_transform.basis * input_direction).normalized()

	# Apply movement
	if is_on_floor():
		velocity.x = rotated_direction.x * move_speed
		velocity.z = rotated_direction.z * move_speed
	else:
		velocity.y += gravity * delta

	move_and_slide()

# Handle camera look
func handle_look() -> void:
	var mouse_delta: Vector2 = Input.get_last_mouse_velocity() * look_sensitivity
	pitch = clamp(pitch - mouse_delta.y, -90, 90)
	$Camera3D.rotation_degrees.x = pitch
	rotation_degrees.y -= mouse_delta.x

# Capture mouse on startup
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
