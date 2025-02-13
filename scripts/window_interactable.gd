extends Interactable

@onready var wind_sound: AudioStreamPlayer3D = $WindSound
@onready var wind_howling: AudioStreamPlayer3D = $WindHowling

@export
var animation_player_left: AnimationPlayer
@export
var animation_player_right: AnimationPlayer

var is_left_window_open := false
var is_right_window_open := false

var can_interact_left := false
var can_interact_right := false

var last_mouse_pos: Vector2

func _ready() -> void:
	GameState.windows_open.connect(func():
		open_left_window()
		open_right_window()
	)

func _input(event: InputEvent) -> void:
	if in_interaction and event is InputEventMouseMotion:
		last_mouse_pos = event.global_position
		
func _process(delta: float) -> void:
	super._process(delta)
	if not in_interaction:
		return
	if Input.is_action_just_pressed("place_or_pickup") and in_interaction:
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
	animation_player_right.play("WindowROpen")
	set_wind_max_db()
	
	$CloseOpenWindow.play()
	await animation_player_right.animation_finished
	$OpenSound.play()
	

func close_right_window() -> void:
	is_right_window_open = false
	animation_player_right.play_backwards("WindowROpen")
	
	$CloseOpenWindow.play()
	await animation_player_right.animation_finished
	$CloseSound.play()

	set_wind_max_db()
	
	if not is_left_window_open:
		GameState.windows_closed.emit()

func _toggle_left_window() -> void:
	if is_left_window_open:
		close_left_window()
	elif not is_left_window_open:
		open_left_window()

func open_left_window() -> void:
	is_left_window_open = true
	animation_player_left.play("WindowLOpen")
	set_wind_max_db()
	
	$CloseOpenWindow.play()
	await animation_player_left.animation_finished
	$OpenSound.play()
	
func close_left_window() -> void:
	is_left_window_open = false
	animation_player_left.play_backwards("WindowLOpen")
	
	$CloseOpenWindow.play()
	await animation_player_left.animation_finished
	$CloseSound.play()
	
	set_wind_max_db()
	
	if not is_right_window_open:
		GameState.windows_closed.emit()

func set_wind_max_db() -> void:
	if is_left_window_open == true or is_right_window_open == true:
		wind_sound.max_db = 3
		wind_howling.volume_db = 6
		
	elif is_left_window_open == false and is_right_window_open == false:
		wind_sound.max_db = -3.3
		wind_howling.volume_db = -28
		
func _on_left_static_body_3d_mouse_entered() -> void:
	can_interact_left = true
	player.show_generic_label("Click to open" if not is_left_window_open else "Click to close", last_mouse_pos)

func _on_left_static_body_3d_mouse_exited() -> void:
	can_interact_left = false
	player.hide_generic_label()

func _on_right_static_body_3d_mouse_entered() -> void:
	can_interact_right = true
	player.show_generic_label("Click to open" if not is_right_window_open else "Click to close", last_mouse_pos)

func _on_right_static_body_3d_mouse_exited() -> void:
	can_interact_right = false
	player.hide_generic_label()
	
	
