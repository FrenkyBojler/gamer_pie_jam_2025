extends Node3D

class_name MainScene

signal mouse_input_event_update(event: InputEventMouse)

@export
var interactables: Array[Interactable] = []

func _on_mouse_input_event_update(event: InputEventMouse) -> void:
	#for interactable in interactables:
	#	interactable.push_events(event)
	pass
