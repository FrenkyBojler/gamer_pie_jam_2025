extends PanelContainer

class_name TextBubble

const panel_new = preload("res://resources/text_bubble_panel_new.tres")
const panel_old = preload("res://resources/text_bubble_panel_old.tres")

@export
var author: Label
@export
var text: TextLabel
@export
var date: Label
@export
var like_button: Button
@export
var ban_button: Button


func switch_to_old() -> void:
	add_theme_stylebox_override("panel", panel_old)
