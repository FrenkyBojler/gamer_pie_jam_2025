extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_timer: Timer = $WaitTimer

func _ready() -> void:
	GameState.windows_open.connect(func():
		text = "The windows blew open!"
		notification_wait()
	)
		
	GameState.fire_out_signal.connect(func():
		text = "The fire went out!"
		notification_wait()
	)
	GameState.pc_power_off.connect(func():
		text = "The power went out!"
		notification_wait()
	)

func notification_wait():
	animation_player.play("info_show")
	
	wait_timer.start()
	await wait_timer.timeout
	
	animation_player.play_backwards("info_show")