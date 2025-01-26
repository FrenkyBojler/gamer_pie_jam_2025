extends Node

signal game_start

signal game_win
signal game_lost(reason: String)

#events
signal pc_power_off
signal windows_open
signal stop_music
signal fire_out_signal

signal windows_closed
signal fire_back_on

var can_interact := false

var freeze_score := 0
var freeze_score_critical_value := 20
signal freeze_score_updated(score: int)

var tired_score := 0
var tired_score_critical_value := 20
signal tired_score_updated(score: int)

var windows_opened := false
var fire_out := false

var windows_open_event_timer: Timer = Timer.new()
var windows_open_event_min_wait_time := 10.0
var windows_open_event_max_wait_time := 30.0

var freeze_score_timer: Timer = Timer.new()

signal posts_score_update(score: int)
var posts_score_critical_value := 20

func _enter_tree() -> void:
	_setup_windows_open_event()
	_setup_freeze_score_timer()
	_setup_fire_out_event()

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
		elif not windows_open:
			freeze_score -= 1
		elif not fire_out:
			freeze_score -= 1

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

func power_off_event() -> void:
	pc_power_off.emit()
	
func fire_out_event_trigger() -> void:
	fire_out_signal.emit()
	fire_out = true

func windows_open_event_trigger() -> void:
	windows_opened = true
	windows_open.emit()

func loose_game(reason: String) -> void:
	freeze_score_timer.stop()
	windows_open_event_timer.stop()
	
	game_lost.emit(reason)
	can_interact = false

func win_game() -> void:
	can_interact = false
	game_win.emit()

func start_game() -> void:
	can_interact = true
	game_start.emit()
	
	get_tree().root.add_child(windows_open_event_timer)
	windows_open_event_timer.start()
	
	get_tree().root.add_child(freeze_score_timer)
	freeze_score_timer.start()

func restart_game() -> void:
	can_interact = false

	freeze_score = 0
	freeze_score_critical_value = 20

	tired_score = 0
	tired_score_critical_value = 20

	windows_opened = false
	fire_out = false

	windows_open_event_timer = Timer.new()
	windows_open_event_min_wait_time = 10.0
	windows_open_event_max_wait_time = 30.0

	freeze_score_timer = Timer.new()

	posts_score_critical_value = 20
	
	_setup_fire_out_event()
	_setup_freeze_score_timer()
	_setup_windows_open_event()
	
	get_tree().reload_current_scene()

func exit_game() -> void:
	get_tree().quit()
