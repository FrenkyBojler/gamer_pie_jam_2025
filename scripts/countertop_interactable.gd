extends Interactable

func _ready() -> void:
	$Kettle.placed.connect(func(): 
		_check_coffee_ready()
	)
	
	$Mug.placed.connect(func():
		_check_coffee_ready()
	)
	
	$Coffee.placed.connect(func():
		_check_coffee_ready()
	)

func _check_coffee_ready() -> void:
	if not $Kettle.is_placeholder and $Kettle.is_boiled and not $Coffee.is_placeholder and not $Mug.is_placeholder:
		$Mug.fill_mug()
