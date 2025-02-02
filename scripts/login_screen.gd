extends PanelContainer

@export
var nickname: LineEdit

@export
var profile_pics_list: HBoxContainer

signal login(nickname: String, pic_index: int, skip_tutorial: bool, sandbox: bool)

var selected_index := 0

func _ready() -> void:
	GameState.can_interact = false
	var index = 0
	
	for profile_pic in profile_pics_list.get_children():
		var profile_pic_button = profile_pic as Button
		profile_pic_button.pressed.connect(func():
			_turn_off_all_buttons()
			profile_pic_button.button_pressed = true
			selected_index = index
		)
		index += 1

func _turn_off_all_buttons() -> void:
	for profile_pic in profile_pics_list.get_children():
		var profile_pic_button = profile_pic as Button
		profile_pic_button.button_pressed = false

func _on_login_button_pressed() -> void:
	if nickname.text.is_empty():
		return
	login.emit(nickname.text, selected_index, false, false)


func _on_button_pressed() -> void:
	if nickname.text.is_empty():
		return
	login.emit(nickname.text, selected_index, true, false)


func _on_line_edit_text_changed(new_text: String) -> void:
	$AudioStreamPlayer3D.play()

func _on_start_sandbox_pressed() -> void:
	login.emit("Sandbox", 0, true, true)