extends Label

class_name InfoLabel

@export var explanation_label: Label
@export var animation_player: AnimationPlayer
@export var wait_timer: Timer

@export var time_to_fade: float = 10.0

func _enter_tree() -> void:
	notification_wait()

func notification_wait():
	animation_player.play("info_show")
	
	await get_tree().create_timer(time_to_fade).timeout
	
	animation_player.play_backwards("info_show")

	await get_tree().create_timer(1.0).timeout
	get_parent().queue_free()
