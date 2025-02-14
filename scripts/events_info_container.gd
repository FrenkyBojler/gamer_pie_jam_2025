extends VBoxContainer

const info_label = preload("res://prefabs/ui/info_label.tscn")

func _ready() -> void:
	GameState.windows_open.connect(func():
		_add_label("The windows blew open", "Close the windows before you freeze!")
	)
	GameState.fire_out_signal.connect(func():
		_add_label("The fire went out", "Find the matches and light it back up!")
	)
	GameState.pc_power_off.connect(func():
		_add_label("The power went out", "Find the breaker and turn it back on!")
	)
	GameState.coffee_drank.connect(func():
		_add_label("You drank the coffee", "Bring fresh cup of coffee to the PC to stay awake!")
	)

func _add_label(text: String, explanation: String) -> void:
	var label_container = info_label.instantiate() as Control
	label_container.get_child(0).text = text
	label_container.get_child(0).explanation_label.text = explanation
	add_child(label_container)
