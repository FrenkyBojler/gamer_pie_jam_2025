extends StaticBody3D

class_name Interactable

@export
var static_camera: Camera3D = null
@export
var collider: CollisionShape3D = null

@onready
var static_camera_orignal_transform: Transform3D = static_camera.global_transform
var camera_transform_from: Transform3D = Transform3D.IDENTITY
var in_interaction := false

var camera_target_transform: Transform3D = Transform3D.IDENTITY

var switch_cam_timer := Timer.new()

func _ready() -> void:
	assert(static_camera != null, "Interactable needs a camera to work properly.")
	assert(collider != null, "Interactable needs a collider to work properly.")

	switch_cam_timer.timeout.connect(switch_cam_timer_timeout)
	switch_cam_timer.one_shot = true
	switch_cam_timer.wait_time = 0.1
	add_child(switch_cam_timer)

func _process(delta: float) -> void:
	static_camera.global_transform = static_camera.global_transform.interpolate_with(camera_target_transform, delta * 10)

func interact(current_camera_transform: Transform3D) -> void:
	collider.disabled = true
	camera_target_transform = static_camera_orignal_transform
	camera_transform_from = current_camera_transform
	static_camera.global_transform = current_camera_transform
	static_camera.current = true
	in_interaction = true

func cancel_interaction() -> void:
	collider.disabled = false
	camera_target_transform = camera_transform_from
	switch_cam_timer.start()

func switch_cam_timer_timeout() -> void:
	in_interaction = false
	static_camera.current = false
