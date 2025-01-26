extends Pickable

@export
var animation_player: AnimationPlayer

var is_filled := false

func _ready() -> void:
	super._ready()
	empty_mug()

func fill_mug() -> void:
	is_filled = true
	animation_player.play("CoffeeState")
	
func empty_mug() -> void:
	is_filled = false
	animation_player.play_backwards("CoffeeState")
