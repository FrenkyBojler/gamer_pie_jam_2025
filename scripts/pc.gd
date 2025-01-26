extends Interactable

func _ready() -> void:
	collider.disabled = true
	
	GameState.game_start.connect(func(): 
		static_camera.current = false
		collider.disabled = false
	)

func _on_breakers_interactable_switch_3_flip(is_on: bool) -> void:
	$CRT2Din3D.pc_ui.visible = is_on
	$CRT2Din3D.power_off.visible = not is_on
