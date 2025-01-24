extends CharacterBody3D

@export var move_speed: float = 5.0
@export var look_sensitivity: float = 0.002
@export var jump_strength: float = 8.0
@export var gravity: float = -20.0

var interactable_object: PhysicsBody3D = null

# Internal variables
var pitch: float = 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame
func _process(delta: float) -> void:
	handle_movement(delta)
	handle_look()
	check_interaction()
	handle_interaction()

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

func check_interaction() -> void:
	# Shoot ray from the center of the screen (considering the camera and it's rotation)
	var ray_from: Vector3 = $Camera3D.global_transform.origin
	var ray_dir: Vector3 = $Camera3D.global_transform.basis.z * -1
	var ray_to: Vector3 = ray_from + ray_dir * 1.8

	# Cast the ray
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from, ray_to))
	if result:
		var collider = result.collider as PhysicsBody3D
		if collider.is_in_group("interactable"):
			interactable_object = collider
			$Control/InteractLabel.visible = true
	else:
		interactable_object = null
		$Control/InteractLabel.visible = false

func handle_interaction() -> void:
	if interactable_object != null and Input.is_action_just_pressed("interact"):
		if interactable_object.has_method("interact"):
			interactable_object.interact()
		else:
			print_debug("missing interact method")
