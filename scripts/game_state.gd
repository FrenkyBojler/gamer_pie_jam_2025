extends Node

signal game_start

signal game_win
signal game_lost(reason: String)

#events
signal pc_power_off
signal windows_open
signal stop_music
signal fire_out_signal
signal notification_recieved

signal windows_closed
signal fire_back_on
signal power_back_on

signal coffee_made
signal coffee_drank

var can_interact := false

var freeze_score := 0
var freeze_score_critical_value := 40
signal freeze_score_updated(score: int)

var tired_score := 0
var tired_score_critical_value := 80
signal tired_score_updated(score: int)

var windows_opened := false
var fire_out := false
var coffee_out := false

var windows_open_event_timer: Timer = Timer.new()
var windows_open_event_min_wait_time := 20.0
var windows_open_event_max_wait_time := 40.0

var power_off_event_timer: Timer = Timer.new()
var power_off_event_min_wait_time := 20.0
var power_off_event_max_wait_time := 40.0

var freeze_score_timer: Timer = Timer.new()
var energy_score_timer: Timer = Timer.new()

signal posts_score_update(score: int)
var posts_score_critical_value := 40

var is_sandbox := false

func _enter_tree() -> void:
	_setup_windows_open_event()
	_setup_freeze_score_timer()
	_setup_fire_out_event()
	_setup_power_off_event()
	_setup_energy_decrease_timer()

	_setup_coffe_state_handler()

	game_lost.connect(func():
		can_interact = false
		freeze_score_timer.stop()
		windows_open_event_timer.stop()
		power_off_event_timer.stop()
	)
	
	game_win.connect(func():
		can_interact = false
		freeze_score_timer.stop()
		windows_open_event_timer.stop()
		power_off_event_timer.stop()
	)

func _setup_energy_decrease_timer() -> void:
	energy_score_timer.wait_time = 2
	energy_score_timer.one_shot = false
	energy_score_timer.autostart = false
	
	energy_score_timer.timeout.connect(func():
		if coffee_out:
			tired_score += 1
		if not coffee_out:
			tired_score -= 1

		if tired_score <= 0:
			tired_score = 0

		tired_score_updated.emit(tired_score)
		if tired_score >= tired_score_critical_value:
			loose_game("tired")
	)

func _setup_coffe_state_handler() -> void:
	coffee_made.connect(func():
		print_debug("Coffee made")
		coffee_out = false
	)
	coffee_drank.connect(func():
		print_debug("Coffee drank")
		coffee_out = true
	)

func _setup_fire_out_event() -> void:
	fire_back_on.connect(func(): fire_out = false)

func _setup_freeze_score_timer() -> void:
	freeze_score_timer.wait_time = 2
	freeze_score_timer.one_shot = false
	freeze_score_timer.autostart = false
	
	freeze_score_timer.timeout.connect(func():
		if windows_opened:
			freeze_score += 1
		if fire_out:
			freeze_score += 1
			
		if not windows_opened and not fire_out:
			freeze_score -= 2

		if freeze_score <= 0:
				freeze_score = 0

		freeze_score_updated.emit(freeze_score)
		if freeze_score >= freeze_score_critical_value:
			loose_game("freeze")
	)

func _setup_windows_open_event() -> void:
	windows_open_event_timer.wait_time = RandomNumberGenerator.new().randf_range(windows_open_event_min_wait_time, windows_open_event_max_wait_time)
	windows_open_event_timer.one_shot = true
	windows_open_event_timer.autostart = false
	windows_open_event_timer.timeout.connect(func(): windows_open_event_trigger())
	windows_closed.connect(func():
		windows_open_event_timer.start(RandomNumberGenerator.new().randf_range(windows_open_event_min_wait_time, windows_open_event_max_wait_time))
		windows_opened = false
	)
	
func notification_recieved_event() -> void:
	notification_recieved.emit()
	
func _setup_power_off_event() -> void:
	power_off_event_timer.wait_time = RandomNumberGenerator.new().randf_range(windows_open_event_min_wait_time, windows_open_event_max_wait_time)
	power_off_event_timer.one_shot = true
	power_off_event_timer.autostart = false
	power_off_event_timer.timeout.connect(func(): power_off_event_trigger())
	power_back_on.connect(func():
		power_off_event_timer.start(RandomNumberGenerator.new().randf_range(power_off_event_min_wait_time, power_off_event_max_wait_time))
)

func power_off_event_trigger() -> void:
	pc_power_off.emit()
	
func fire_out_event_trigger() -> void:
	fire_out_signal.emit()
	fire_out = true

func windows_open_event_trigger() -> void:
	windows_opened = true
	windows_open.emit()

func loose_game(reason: String) -> void:
	if is_sandbox:
		return

	freeze_score_timer.stop()
	windows_open_event_timer.stop()
	power_off_event_timer.stop()
	
	game_lost.emit(reason)
	can_interact = false

func win_game() -> void:
	can_interact = false
	game_win.emit()

func start_game(tutorial_skiped: bool, is_sandbox: bool = false) -> void:
	can_interact = true
	game_start.emit()

	self.is_sandbox = is_sandbox

	if is_sandbox:
		return
	
	get_tree().root.add_child(windows_open_event_timer)
	windows_open_event_timer.start()
	
	get_tree().root.add_child(freeze_score_timer)
	freeze_score_timer.start()

	get_tree().root.add_child(energy_score_timer)
	energy_score_timer.start()
	
	get_tree().root.add_child(power_off_event_timer)
	if tutorial_skiped:
		power_off_event_timer.start()

func restart_game() -> void:
	can_interact = false

	freeze_score = 0
	freeze_score_critical_value = 20

	tired_score = 0
	tired_score_critical_value = 20
	coffee_out = false


	windows_opened = false
	fire_out = false
	coffee_out = false

	windows_open_event_timer = Timer.new()
	windows_open_event_min_wait_time = 10.0
	windows_open_event_max_wait_time = 30.0
	
	power_off_event_timer = Timer.new()
	power_off_event_min_wait_time = 10.0
	power_off_event_max_wait_time = 30.0

	freeze_score_timer = Timer.new()
	energy_score_timer = Timer.new()


	posts_score_critical_value = 20
	
	_setup_fire_out_event()
	_setup_freeze_score_timer()
	_setup_windows_open_event()
	
	get_tree().reload_current_scene()

func exit_game() -> void:
	get_tree().quit()
