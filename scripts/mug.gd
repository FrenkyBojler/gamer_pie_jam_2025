extends Pickable

@export
var animation_player: AnimationPlayer

func fill_mug() -> void:
	animation_player.play("CoffeeState")
	
func empty_mug() -> void:
	animation_player.play_backwards("CoffeeState")
