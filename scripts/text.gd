extends Label

class_name TextLabel

signal text_changed

func set_current_text(text: String) -> void:
	self.text = text
	text_changed.emit()
