extends CharacterBody3D

class_name Player

const look_at_interaction_cursor = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0032.png")
const crosshair_cursor = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0200.png")

const default_cursor = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0201.png")
const interaction_cursor_active = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0134.png")
const grab_cursor = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0139.png")
const place_cursor = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0135.png")
const cannot_interact_cursor = preload("res://assets/textures/kenney_cursor-pixel-pack/Tiles/tile_0015.png")

@export var move_speed: float = 5.0
@export var look_sensitivity: float = 0.002
@export var jump_strength: float = 8.0
@export var gravity: float = -20.0

@export var camera: Camera3D = null
@export var carry_spot: Node3D = null

@export var pc_interactable: Interactable

@export var step_delay_time: float = 0.5

@onready var step_delay: Timer = $PlayerStep/StepDelay

var interactable_object: Interactable = null
var in_interaction := false
var canceled_interaction := false

var picked_object: Pickable = null
var pickable_object: Pickable = null
var placeable_object: Pickable = null

var can_pickup := false
var can_place := false

var pitch: float = 0.0

var current_mouse_pos: Vector2

func _ready() -> void:
	assert(camera != null, "Player needs a camera to work properly.")
	assert(carry_spot != null, "Player needs a carry spot to work properly.")



	$Control/Crosshair.visible = false
	_switch_crosshair_to_default()

	hide_all_labels()
	Input.set_custom_mouse_cursor(interaction_cursor_active, Input.CURSOR_ARROW)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	GameState.game_start.connect(func(): 
		visible = true
		$Control/Crosshair.visible = true
		GameState.can_interact = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true
	)

	GameState.game_lost.connect(func(reason: String) :
		visible = false
		$Control/Crosshair.visible = false
		hide_all_labels()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera.current = false
	)

	GameState.game_win.connect(func() :
		visible = false
		$Control/Crosshair.visible = false
		hide_all_labels()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera.current = false
	)
	
func _switch_crosshair_to(texture: Texture2D) -> void:
	$Control/Crosshair.texture = texture

func _switch_crosshair_to_look_at() -> void:
	_switch_crosshair_to(look_at_interaction_cursor)

func _switch_crosshair_to_default() -> void:
	_switch_crosshair_to(crosshair_cursor)
	
func _switch_cursor_to(texture: Texture2D) -> void:
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW)

func _switch_cursor_to_default() -> void:
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW)
	
func _switch_cursor_to_active() -> void:
	Input.set_custom_mouse_cursor(interaction_cursor_active, Input.CURSOR_ARROW)

func _switch_cursor_to_grab() -> void:
	Input.set_custom_mouse_cursor(grab_cursor, Input.CURSOR_ARROW)
	
func _switch_cursor_to_place() -> void:
	Input.set_custom_mouse_cursor(place_cursor, Input.CURSOR_ARROW)
	
func _switch_cursor_to_cannot_interact() -> void:
	Input.set_custom_mouse_cursor(cannot_interact_cursor, Input.CURSOR_ARROW)

func _input(event: InputEvent) -> void:
	if GameState.can_interact and event is InputEventMouseButton and not in_interaction:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event is InputEventMouseMotion:
		current_mouse_pos = event.position

func _process(delta: float) -> void:
	if not GameState.can_interact:
		return

	handle_interaction()
	
	if Input.is_action_just_pressed("place_or_pickup"):
		if can_pickup:
			_pickup()
		elif can_place:
			_place()

	if not in_interaction:
		check_interaction()
		handle_movement(delta)
		handle_look()
		handle_animations()
		_play_walking_sound()

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

func _play_walking_sound() -> void:
	
	if velocity.length() > 0 and !$PlayerStep.playing and step_delay.is_stopped():
		$PlayerStep.pitch_scale = randf_range(0.9, 1.1)  # Slight variation
		$PlayerStep.play()
		
		step_delay.wait_time = step_delay_time
		step_delay.start()

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
			_switch_crosshair_to_look_at()
	else:
		interactable_object = null
		_switch_crosshair_to_default()

func handle_interaction() -> void:
	if interactable_object != null and not in_interaction and Input.is_action_just_pressed("interact"):
		start_interaction()
	elif in_interaction and (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("cancel_interact")):
		cancel_interaction()

func start_interaction() -> void:
	if interactable_object is Interactable:
		$AnimationPlayer.stop()
		$CollisionShape3D.disabled = true
		in_interaction = true
		camera.current = false
		interactable_object.interact(camera.global_transform)

		$Control/Crosshair.visible = false
		$Control/InteractLabel.visible = false

		Input.set_custom_mouse_cursor(interaction_cursor_active, Input.CURSOR_ARROW)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		print_debug("missing interact method")

func cancel_interaction() -> void:
	$CollisionShape3D.disabled = false
	interactable_object.cancel_interaction()
	interactable_object = null
	in_interaction = false

	$Control/Crosshair.visible = true
	$Control/InteractLabel.visible = false

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func handle_animations() -> void:
	if velocity.length() > 0 and not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("walk")
	elif velocity.length() == 0 and $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()

func _pickup() -> void:
	$PickUp.play()
	picked_object = pickable_object.duplicate()
	
	if pickable_object is Kettle:
		print_debug(pickable_object.is_boiled)
	if picked_object is Kettle:
		print_debug(picked_object.is_boiled)
	
	$Camera3D.add_child(picked_object)
	picked_object.global_position = $Camera3D/CarrySpot.global_position
	pickable_object.pickup()
	
	hide_pickup_object_label()
	show_place_object_label(current_mouse_pos, pickable_object)

func _place() -> void:
	$PlaceDown.play()
	placeable_object.place()
	if placeable_object is Kettle and picked_object is Kettle:
		placeable_object.is_boiled = picked_object.is_boiled
	
	picked_object.queue_free()
	picked_object = null
	
	hide_place_object_label()
	show_pickup_object_label(current_mouse_pos, placeable_object)
	
	
func hide_all_labels() -> void:
	hide_place_object_label()
	hide_missing_object_label()
	hide_pickup_object_label()
	hide_generic_label()
	$Control/InteractLabel.visible = false

func show_generic_label(text: String, pos: Vector2) -> void:
	#$Control/GenericLabel.text = text
	#$Control/GenericLabel.global_position = pos
	#$Control/GenericLabel.visible = true
	_switch_cursor_to_active()

func hide_generic_label() -> void:
	#$Control/GenericLabel.visible = false
	_switch_cursor_to_default()

func show_place_object_label(pos: Vector2, placeable: Pickable) -> void:
	can_place = true
	placeable_object = placeable
	#$Control/ClickToPlaceLabel.global_position = pos
	#$Control/ClickToPlaceLabel.visible = true
	_switch_cursor_to_place()
	
func hide_place_object_label() -> void:
	can_place = false
	#$Control/ClickToPlaceLabel.visible = false
	_switch_cursor_to_default()
	
func show_missing_object_label(pos: Vector2) -> void:
	#$Control/MissingObjectLabel.global_position = pos
	#$Control/MissingObjectLabel.visible = true
	_switch_cursor_to_cannot_interact()

func hide_missing_object_label() -> void:
	_switch_cursor_to_default()

func show_pickup_object_label(pos: Vector2, pickable: Pickable) -> void:
	can_pickup = true
	pickable_object = pickable
	#$Control/PickupObjectLabel.global_position = pos
	#$Control/PickupObjectLabel.visible = true
	_switch_cursor_to_grab()
	
func hide_pickup_object_label() -> void:
	can_pickup = false
	#$Control/PickupObjectLabel.visible = false
	_switch_cursor_to_default()
