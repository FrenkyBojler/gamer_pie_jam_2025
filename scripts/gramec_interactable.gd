extends Interactable

@export
var anim_player: AnimationPlayer

var is_playing := true
var can_interact := false

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

func _spin_handle() -> void:
	if can_interact:
		anim_player.play("GramophoneHandleSpin")

func _on_static_body_3d_mouse_entered() -> void:
	can_interact = true
	player.show_generic_label("Click to spin", last_mouse_pos)

func _on_static_body_3d_mouse_exited() -> void:
	can_interact = false
	player.hide_generic_label()
