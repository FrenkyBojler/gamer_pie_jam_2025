extends Interactable

@export
var anim_player: AnimationPlayer
var can_interact_with_door := false
var is_door_open := false

var last_mouse_pos: Vector2

func _input(event: InputEvent) -> void:
	if in_interaction and event is InputEventMouseMotion:
		last_mouse_pos = event.global_position

func _process(delta: float) -> void:
	super._process(delta)
	if not in_interaction:
		return
	if Input.is_action_just_pressed("place_or_pickup"):
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

func close_door() -> void:
	is_door_open = false
	anim_player.play_backwards("FurnaceDoorOpen")


func _on_furnace_col_mouse_entered() -> void:
	can_interact_with_door = true
	player.show_generic_label("Click to open" if not is_door_open else "Click to close", last_mouse_pos)

func _on_furnace_col_mouse_exited() -> void:
	can_interact_with_door = false
