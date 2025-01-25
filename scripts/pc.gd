extends Interactable

func _ready() -> void:
	collider.disabled = true
	
	GameState.game_start.connect(func(): 
		static_camera.current = false
		collider.disabled = false
	)
