extends Interactable

func _ready() -> void:
	GameState.fire_out_signal.connect(func():
		for item in pickable_objects:
			item.place()
	)
