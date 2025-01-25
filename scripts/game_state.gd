extends Node

signal game_start

var can_interact := false

func start_game() -> void:
	can_interact = true
	game_start.emit()
