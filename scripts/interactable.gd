extends StaticBody3D

class_name Interactable

@export
var player: Player = null
@export
var static_camera: Camera3D = null
@export
var collider: CollisionShape3D = null
@export
var pickable_objects: Array[Pickable] = []

@onready
var static_camera_orignal_transform: Transform3D = static_camera.global_transform
var camera_transform_from: Transform3D = Transform3D.IDENTITY

var in_interaction := false

var camera_target_transform: Transform3D = Transform3D.IDENTITY

var switch_cam_timer := Timer.new()

func _enter_tree() -> void:
	assert(player != null, "Interactable need a player to work properly.")
	assert(static_camera != null, "Interactable needs a camera to work properly.")
	assert(collider != null, "Interactable needs a collider to work properly.")

	_setup_switch_cam_timer()
	_setup_pickables()

func _setup_switch_cam_timer() -> void:
	switch_cam_timer.timeout.connect(switch_cam_timer_timeout)
	switch_cam_timer.one_shot = true
	switch_cam_timer.wait_time = 0.1
	switch_cam_timer.autostart = false
	add_child(switch_cam_timer)

func _setup_pickables() -> void:
	for pickable in pickable_objects:
		pickable.setup(player, self)

func _show_pickables_placeholder() -> void:
	for pickable in pickable_objects:
		if pickable.is_placeholder:
			pickable.visible = true

func _hide_pickables_placeholder() -> void:
	for pickable in pickable_objects:
		if pickable.is_placeholder:
			pickable.visible = false
		else:
			pickable.hide_outline()

func _process(delta: float) -> void:
	if not GameState.can_interact:
		return
	static_camera.global_transform = static_camera.global_transform.interpolate_with(camera_target_transform, delta * 10)

func _on_interact() -> void:
	pass

func interact(current_camera_transform: Transform3D) -> void:
	collider.disabled = true
	camera_target_transform = static_camera_orignal_transform
	camera_transform_from = current_camera_transform
	static_camera.global_transform = current_camera_transform
	static_camera.current = true
	_show_pickables_placeholder()
	
	await get_tree().create_timer(0.1).timeout
	_on_interact()
	in_interaction = true
	
func _on_cancel_interaction() -> void:
	pass

func cancel_interaction() -> void:
	collider.disabled = false
	camera_target_transform = camera_transform_from
	switch_cam_timer.start()
	_hide_pickables_placeholder()
	player.hide_all_labels()
	_on_cancel_interaction()
	in_interaction = false

func switch_cam_timer_timeout() -> void:
	in_interaction = false
	static_camera.current = false
