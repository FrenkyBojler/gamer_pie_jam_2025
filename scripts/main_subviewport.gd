extends SubViewport


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		$SampleScene.mouse_input_event_update.emit(event)
