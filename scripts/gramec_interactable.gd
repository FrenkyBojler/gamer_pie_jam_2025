extends Interactable

@export
var anim_player: AnimationPlayer

var is_playing := true
var can_interact := false
var can_interact_with_button := false

var last_mouse_pos: Vector2

func _ready() -> void:
	anim_player.play("GramophoneRecordSpin")

func _input(event: InputEvent) -> void:
	if in_interaction and event is InputEventMouseMotion:
		last_mouse_pos = event.global_position

func _process(delta: float) -> void:
	super._process(delta)
	if not in_interaction:
		return
	if Input.is_action_just_pressed("place_or_pickup"):
		_spin_handle()
		_push_button()

func _push_button() -> void:
	if can_interact_with_button:
		anim_player.play("button")
		await get_tree().create_timer(1).timeout
		anim_player.play("GramophoneRecordSpin")

func _spin_handle() -> void:
	if can_interact:
		anim_player.play("GramophoneHandleSpin")

func _on_static_body_3d_mouse_entered() -> void:
	can_interact = true
	player.show_generic_label("Click to spin", last_mouse_pos)

func _on_static_body_3d_mouse_exited() -> void:
	can_interact = false
	player.hide_generic_label()

func _on_button_col_mouse_entered() -> void:
	can_interact_with_button = true
	player.show_generic_label("Click to push", last_mouse_pos)

func _on_button_col_mouse_exited() -> void:
	can_interact_with_button = false
	player.hide_generic_label()
