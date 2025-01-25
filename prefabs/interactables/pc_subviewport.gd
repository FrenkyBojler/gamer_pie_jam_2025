extends SubViewport

func _input(event: InputEvent) -> void:
	for child in get_children():
		if child is Control:
			(child as Control).accept_event()
