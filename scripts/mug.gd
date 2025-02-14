extends Pickable

class_name Mug

@export
var animation_player: AnimationPlayer

var is_filled := false

@onready
var drink_timer: Timer = $DrinkTimer
var time_to_drink := 25.0
var current_time_to_drink := 0.0

var full_cup_animation_time := 0.8333
var empty_cup_animation := 0.0

func _ready() -> void:
	super._ready()

	GameState.game_start.connect(func():
		fill_mug()
	)

func fill_mug() -> void:
	is_filled = true
	drink_timer.stop()
	current_time_to_drink = 0
	animation_player.play("CoffeeState")
	_start_drink_timer()

func _start_drink_timer() -> void:
	if current_interactable is PCInteractable:
		drink_timer.start()
	
func empty_mug() -> void:
	is_filled = false
	animation_player.play_backwards("CoffeeState")

func set_current_drink_amount(drink_amount: float) -> void:
	current_time_to_drink = drink_amount
	animation_player.current_animation = "CoffeeState"
	animation_player.seek(full_cup_animation_time - (current_time_to_drink / time_to_drink) * full_cup_animation_time, true)
	animation_player.pause()

func _on_drink_timer_timeout() -> void:
	current_time_to_drink += 0.1

	set_current_drink_amount(current_time_to_drink)

	if current_time_to_drink >= time_to_drink:
		GameState.coffee_drank.emit()
		is_filled = false
		current_time_to_drink = 0
		drink_timer.stop()

func _on_picked_up() -> void:
	drink_timer.paused = true

func _on_placed() -> void:
	if current_interactable is PCInteractable and drink_timer.paused:
		_resume_drinking()

func _resume_drinking() -> void:
	drink_timer.paused = false
	GameState.coffee_made.emit()