extends CharacterBody3D

class_name Player

const interaction_cursor_non_active = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0135.png")
const interaction_cursor_active = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0134.png")

@export var move_speed: float = 5.0
@export var look_sensitivity: float = 0.002
@export var jump_strength: float = 8.0
@export var gravity: float = -20.0

@export var camera: Camera3D = null
@export var carry_spot: Node3D = null

var interactable_object: Interactable = null
var in_interaction := false
var canceled_interaction := false

var picked_object: Pickable = null
var pickable_object: Pickable = null
var placeable_object: Pickable = null

var can_pickup := false
var can_place := false

var pitch: float = 0.0

func _ready() -> void:
	assert(camera != null, "Player needs a camera to work properly.")
	assert(carry_spot != null, "Player needs a carry spot to work properly.")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not in_interaction:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		pass
func _process(delta: float) -> void:
	handle_interaction()
	
	if Input.is_action_pressed("place_or_pickup"):
		if can_pickup:
			_pickup()
		elif can_place:
			_place()

	if not in_interaction:
		check_interaction()
		handle_movement(delta)
		handle_look()
		handle_animations()

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
	velocity.x = rotated_direction.x * move_speed
	velocity.z = rotated_direction.z * move_speed

	move_and_slide()

# Handle camera look
func handle_look() -> void:
	var mouse_delta: Vector2 = Input.get_last_mouse_velocity() * look_sensitivity
	pitch = clamp(pitch - mouse_delta.y, -90, 90)
	$Camera3D.rotation_degrees.x = pitch
	rotation_degrees.y -= mouse_delta.x

func check_interaction() -> void:
	var ray_from: Vector3 = $Camera3D.global_transform.origin
	var ray_dir: Vector3 = $Camera3D.global_transform.basis.z * -1
	var ray_to: Vector3 = ray_from + ray_dir * 1.8

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from, ray_to))
	if result:
		var collider = result.collider
		if collider.is_in_group("interactable") and collider is Interactable:
			interactable_object = collider as Interactable
			$Control/InteractLabel.visible = true
	else:
		interactable_object = null
		$Control/InteractLabel.visible = false

func handle_interaction() -> void:
	if interactable_object != null and not in_interaction and Input.is_action_just_pressed("interact"):
		start_interaction()
	elif in_interaction and (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("interact")):
		cancel_interaction()

func start_interaction() -> void:
	if interactable_object is Interactable:
		in_interaction = true
		camera.current = false
		interactable_object.interact(camera.global_transform)

		$Control/Crosshair.visible = false
		$Control/InteractLabel.visible = false

		Input.set_custom_mouse_cursor(interaction_cursor_non_active, Input.CURSOR_ARROW)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		print_debug("missing interact method")

func cancel_interaction() -> void:
	interactable_object.cancel_interaction()
	interactable_object = null
	in_interaction = false

	$Control/Crosshair.visible = true
	$Control/InteractLabel.visible = false

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func handle_animations() -> void:
	if velocity.length() > 0:
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("idle")
		
func _pickup() -> void:
	picked_object = pickable_object.duplicate()
	$Camera3D.add_child(picked_object)
	picked_object.global_position = $Camera3D/CarrySpot.global_position
	hide_pickup_object_label()
	pickable_object.pickup()

func _place() -> void:
	placeable_object.place()
	picked_object.queue_free()
	picked_object = null
	hide_place_object_label()
	
func hide_all_labels() -> void:
	hide_place_object_label()
	hide_missing_object_label()
	hide_pickup_object_label()

func show_place_object_label(pos: Vector2, placeable: Pickable) -> void:
	can_place = true
	placeable_object = placeable
	$Control/ClickToPlaceLabel.global_position = pos
	$Control/ClickToPlaceLabel.visible = true

func hide_place_object_label() -> void:
	can_place = false
	$Control/ClickToPlaceLabel.visible = false

func show_missing_object_label(pos: Vector2) -> void:
	$Control/MissingObjectLabel.global_position = pos
	$Control/MissingObjectLabel.visible = true

func hide_missing_object_label() -> void:
	$Control/MissingObjectLabel.visible = false

func show_pickup_object_label(pos: Vector2, pickable: Pickable) -> void:
	can_pickup = true
	pickable_object = pickable
	$Control/PickupObjectLabel.global_position = pos
	$Control/PickupObjectLabel.visible = true

func hide_pickup_object_label() -> void:
	can_pickup = false
	$Control/PickupObjectLabel.visible = false
