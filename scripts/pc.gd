extends Interactable

var can_interact_with_monitor := false
var is_online := true

var last_mouse_pos: Vector2

func _on_cancel_interaction() -> void:
	$GoOnlineArea.monitoring = true
	$GoOnlineArea/CollisionShape3D.disabled = false
	$CameraMonitor.current = false
	$CameraStatic.current = false
	is_online = false

func _input(event: InputEvent) -> void:
	if in_interaction and event is InputEventMouseMotion:
		last_mouse_pos = event.global_position
		
func _process(delta: float) -> void:
	super._process(delta)
	if not in_interaction:
		return
	if Input.is_action_just_pressed("place_or_pickup"):
		go_online()

func go_online() -> void:
	if can_interact_with_monitor and not is_online:
		$GoOnlineArea.monitoring = false
		$GoOnlineArea/CollisionShape3D.disabled = true
		$CameraMonitor.current = true
		$CameraStatic.current = false
		is_online = true
		player.hide_generic_label()

func _ready() -> void:
	collider.disabled = true
	
	GameState.game_start.connect(func(): 
		static_camera.current = false
		collider.disabled = false
		_on_cancel_interaction()
	)

func _on_breakers_interactable_switch_3_flip(is_on: bool) -> void:
	$CRT2Din3D.pc_ui.visible = is_on
	$CRT2Din3D.power_off.visible = not is_on

func _on_go_online_area_mouse_entered() -> void:
	if is_online:
		return
	can_interact_with_monitor = true
	player.show_generic_label("Go online", last_mouse_pos)

func _on_go_online_area_mouse_exited() -> void:
	if is_online:
		return
	can_interact_with_monitor = false
	player.hide_generic_label()
