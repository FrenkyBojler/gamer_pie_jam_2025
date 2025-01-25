extends Control

const boss_profile_pic = preload("res://assets/textures/ui/Boss.PNG")

const user_profile_pic_1 = preload("res://assets/textures/ui/Dudette.PNG")
const user_profile_pic_2 = preload("res://assets/textures/ui/Grumpster.PNG")
const user_profile_pic_3 = preload("res://assets/textures/ui/Havin.PNG")
const user_profile_pic_4 = preload("res://assets/textures/ui/OutdoorBoi.PNG")
const user_profile_pic_5 = preload("res://assets/textures/ui/Randall.PNG")
const user_profile_pic_6 = preload("res://assets/textures/ui/Rando.PNG")

var profile_pics = [user_profile_pic_1, user_profile_pic_2, user_profile_pic_3, user_profile_pic_4, user_profile_pic_5, user_profile_pic_6]

var on_ban: Callable
var on_promote: Callable

var alignment: String

func setup(data: Dictionary, user_pic_index: int, on_promote: Callable, on_ban: Callable) -> void:
	self.on_ban = on_ban
	self.on_promote = on_promote
	
	get_profile_pic(user_pic_index)
	
	alignment = data["alignment"]
	
	$HBoxContainer/TextBubble.author.text = data["name"]
	$HBoxContainer/TextBubble.text.set_current_text(data["text"])
	$HBoxContainer/TextBubble.date.text = data["date"]
	
func get_profile_pic(user_pic_index: int) -> void:
	var tries = 0
	var index = RandomNumberGenerator.new().randi_range(0, profile_pics.size() - 1)
	
	while index == user_pic_index or tries < 10:
		index = RandomNumberGenerator.new().randi_range(0, profile_pics.size() - 1)
		tries += 1

	$HBoxContainer/TextureRect.texture = profile_pics[index]

func _ready() -> void:
	$HBoxContainer/TextBubble.like_button.pressed.connect(_on_like_button_click)
	$HBoxContainer/TextBubble.ban_button.pressed.connect(_on_ban_button_click)

func _on_like_button_click() -> void:
	on_promote.call(alignment)

func _on_ban_button_click() -> void:
	on_ban.call(alignment)
