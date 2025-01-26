extends Node

signal game_start

signal game_win
signal game_lost(reason: String)

var can_interact := false

func loose_game(reason: String) -> void:
	can_interact = false
	game_lost.emit(reason)

func win_game() -> void:
	can_interact = false
	game_win.emit()

func start_game() -> void:
	can_interact = true
	game_start.emit()

func restart_game() -> void:
	get_tree().reload_current_scene()

func exit_game() -> void:
	get_tree().quit()
