extends Control

func setup(author: String, text: String, date: String) -> void:
	$TextBubble.author.text = author
	$TextBubble.text.set_current_text(text)
	$TextBubble.date.text = date

func _ready() -> void:
	$TextBubble.like_button.pressed.connect(_on_like_button_click)
	$TextBubble.ban_button.pressed.connect(_on_ban_button_click)
	
	setup("Kokotek", "TOPIC is one of those ideas that sounds good on paper but fails irl.", "Taky neco")

func _on_like_button_click() -> void:
	print_debug("Like")
	
func _on_ban_button_click() -> void:
	print_debug("Ban")
