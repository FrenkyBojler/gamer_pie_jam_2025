extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_timer: Timer = $WaitTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.windows_open.connect(func():
		print("window open")
		text = "The Window blew open!"
		notification_wait()
		)
		
	GameState.pc_power_off.connect(func():
		text = "The PCs power went out!"
		notification_wait()
		)
		
	GameState.fire_out_signal.connect(func():
		text = "The Fire went out!"
		notification_wait()
		)
	GameState.pc_power_off.connect(func():
		text = "The Power went out!"
		notification_wait()
		)

	pass # Replace with function body.
func notification_wait():
	animation_player.play("info_show")
	
	wait_timer.start()
	await wait_timer.timeout
	
	animation_player.play_backwards("info_show")
	
	print("ass")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
