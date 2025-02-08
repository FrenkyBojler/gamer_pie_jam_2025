extends Interactable

@export
var animation_player_left: AnimationPlayer
@export
var animation_player_right: AnimationPlayer

var is_left_window_open := false
var is_right_window_open := false

var can_interact_left := false
var can_interact_right := false

var last_mouse_pos: Vector2

@onready var step_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var min_delay: float = 5.0  # Minimum time between plays
@export var max_delay: float = 15.0  # Maximum time between plays
@export var min_pitch: float = 0.8  # Minimum pitch scale
@export var max_pitch: float = 1.2  # Maximum pitch scale




func _input(event: InputEvent) -> void:
	if in_interaction and event is InputEventMouseMotion:
		last_mouse_pos = event.global_position
		
func _process(delta: float) -> void:
	super._process(delta)
	if not in_interaction:
		return
	if in_interaction and Input.is_action_just_pressed("place_or_pickup"):
		_toggle_windows()
		
func _toggle_windows() -> void:
	if can_interact_left:
		_toggle_left_window()
		player.hide_generic_label()
	elif can_interact_right:
		_toggle_right_window()
		player.hide_generic_label()

func _toggle_right_window() -> void:
	if is_right_window_open:
		close_right_window()
	elif not is_right_window_open:
		open_right_window()

func open_right_window() -> void:
	is_right_window_open = true
	animation_player_right.play("FridgeBottomDoor")
	$OpenCloseSound.play()
	

func close_right_window() -> void:
	is_right_window_open = false
	animation_player_right.play_backwards("FridgeBottomDoor")
	$OpenCloseSound.play()

func _toggle_left_window() -> void:
	if is_left_window_open:
		close_left_window()
	elif not is_left_window_open:
		open_left_window()

func open_left_window() -> void:
	is_left_window_open = true
	animation_player_left.play("FridgeTopDoor")
	$OpenCloseSound.play()

func close_left_window() -> void:
	is_left_window_open = false
	animation_player_left.play_backwards("FridgeTopDoor")
	$OpenCloseSound.play()

func _on_left_col_mouse_entered() -> void:
	can_interact_left = true
	player.show_generic_label("Click to open" if not is_left_window_open else "Click to close", last_mouse_pos)

func _on_left_col_mouse_exited() -> void:
	can_interact_left = false
	player.hide_generic_label()

func _on_right_col_mouse_entered() -> void:
	can_interact_right = true
	player.show_generic_label("Click to open" if not is_right_window_open else "Click to close", last_mouse_pos)

func _on_right_col_mouse_exited() -> void:
	can_interact_right = false
	player.hide_generic_label()

func _on_static_body_3d_mouse_entered() -> void:
	_on_right_col_mouse_entered()

func _on_static_body_3d_mouse_exited() -> void:
	_on_right_col_mouse_exited()

func _on_downbody_mouse_entered() -> void:
	_on_left_col_mouse_entered()

func _on_downbody_mouse_exited() -> void:
	_on_left_col_mouse_exited()

func _ready():
	play_random_sound()

func play_random_sound():
	
	var next_play_time = randf_range(min_delay, max_delay)
	await get_tree().create_timer(next_play_time).timeout
	print("next play time:",next_play_time)
	if not step_sound or not step_sound.stream:
		push_warning("AudioStreamPlayer is missing or has no audio stream!")
		return
	
	# Randomize pitch
	step_sound.pitch_scale = randf_range(min_pitch, max_pitch)
	
	# Play the sound
	step_sound.play()
	print("Palying steps")
	# Wait for the sound to finish playing
	await step_sound.finished
	# Schedule next play with random delay
	
	

	

	
	play_random_sound()
