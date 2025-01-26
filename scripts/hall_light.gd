extends Node3D

func _on_breakers_interactable_switch_2_flip(is_on: bool) -> void:
	visible = is_on
