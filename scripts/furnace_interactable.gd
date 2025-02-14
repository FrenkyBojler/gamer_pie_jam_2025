extends Interactable

class_name FurnaceInteractable

@export
var anim_player: AnimationPlayer
var can_interact_with_door := false
var is_door_open := false

var last_mouse_pos: Vector2

var fire_is_lit := true

func _ready() -> void:
	GameState.game_start.connect(func():
		light_fire()
	)
	
	$Kettle.placed.connect(func():
		if fire_is_lit:
			$Kettle.is_boiled = true
	)
	
func light_fire() -> void:
	$FireCrackling.play();
	$FireTimer.start()
	$FireLight.visible = true
	GameState.fire_back_on.emit()
	fire_is_lit = true
	$Furace/FuraceBase/FuraceDoor/FurnaceCol/CollisionShape3D.disabled = true

func _input(event: InputEvent) -> void:
	if in_interaction and event is InputEventMouseMotion:
		last_mouse_pos = event.global_position

func _process(delta: float) -> void:
	super._process(delta)
	if not in_interaction:
		return
	if in_interaction and Input.is_action_just_pressed("place_or_pickup"):
		toggle_door()

func toggle_door() -> void:
	if not can_interact_with_door:
		return
	if is_door_open:
		close_door()
	elif not is_door_open:
		open_door()
	player.hide_generic_label()

func open_door() -> void:
	is_door_open = true
	anim_player.play("FurnaceDoorOpen")
	$OpenSound.play()

func close_door() -> void:
	is_door_open = false
	anim_player.play_backwards("FurnaceDoorOpen")
	$CloseSound.play()

	if not $Timber1.is_placeholder and not $Timber2.is_placeholder and not $Timber3.is_placeholder:
		light_fire()

		if not $Kettle.is_placeholder:
			$Kettle.is_boiled = true

func _on_furnace_col_mouse_entered() -> void:
	can_interact_with_door = true
	player.show_generic_label("Click to open" if not is_door_open else "Click to close", last_mouse_pos)

func _on_furnace_col_mouse_exited() -> void:
	can_interact_with_door = false

func _on_fire_timer_timeout() -> void:
	$FireCrackling.stop()
	$FireLight.visible = false
	$Furace/FuraceBase/FuraceDoor/FurnaceCol/CollisionShape3D.disabled = false
	GameState.fire_out_event_trigger()
	fire_is_lit = false
	for item in pickable_objects:
		item.pickup()
