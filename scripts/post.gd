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
var adjust_score: Callable

var is_boss := false

var alignment: String

func setup(data: Dictionary, user_pic_index: int, on_promote: Callable, on_ban: Callable, adjust_score: Callable, is_boss: bool) -> void:
	self.on_ban = on_ban
	self.on_promote = on_promote
	self.adjust_score = adjust_score
	self.is_boss = is_boss
	
	get_profile_pic(user_pic_index, is_boss)
	
	alignment = data["alignment"]
	
	$HBoxContainer/TextBubble.author.text = data["name"]
	$HBoxContainer/TextBubble.text.set_current_text(data["text"])
	$HBoxContainer/TextBubble.date.text = data["date"]
	
	if data.has("tutorial") and data["tutorial"] != null:
		if data["tutorial"] == 0:
			$HBoxContainer/TextBubble.ban_button.visible = false
		if data["tutorial"] == 1:
			$HBoxContainer/TextBubble.like_button.visible = false
			
	if not is_boss:
		$Timer.start()

func get_profile_pic(user_pic_index: int, is_boss: bool) -> void:
	if is_boss:
		$HBoxContainer/TextureRect.texture = boss_profile_pic
		return
		
	var tries = 0
	var index = RandomNumberGenerator.new().randi_range(0, profile_pics.size() - 1)
	
	while index == user_pic_index or tries < 10:
		index = RandomNumberGenerator.new().randi_range(0, profile_pics.size() - 1)
		tries += 1

	$HBoxContainer/TextureRect.texture = profile_pics[index]

func _ready() -> void:
	$HBoxContainer/TextBubble.like_button.pressed.connect(_on_like_button_click)
	$HBoxContainer/TextBubble.ban_button.pressed.connect(_on_ban_button_click)

func _hide_buttons() -> void:
	$HBoxContainer/TextBubble.like_button.visible = false
	$HBoxContainer/TextBubble.ban_button.visible = false
	$HBoxContainer/TextBubble.switch_to_old()

func _on_like_button_click() -> void:
	on_promote.call(alignment)
	_hide_buttons()
	$Timer.stop()

func _on_ban_button_click() -> void:
	on_ban.call(alignment)
	_hide_buttons()
	$Timer.stop()

func _on_timer_timeout() -> void:
	adjust_score.call(alignment)
	_hide_buttons()
