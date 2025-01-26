extends Node2D3D

class_name PC2D3D

@export
var pc_ui: Control

@export
var power_off: Control

@export
var game_win: Control
@export
var game_loose_points: Control
@export
var game_loose_freeze: Control
@export
var game_loose_tired: Control

func _on_restart_button_pressed() -> void:
	GameState.restart_game()

func _on_exit_button_pressed() -> void:
	GameState.exit_game()
