extends Interactable

signal switch_1_flip(is_on: bool)
signal switch_2_flip(is_on: bool)
signal switch_3_flip(is_on: bool)
signal switch_4_flip(is_on: bool)

@export
var animation_player: AnimationPlayer

@export
var switches_col: Array[StaticBody3D]
@export
var switches_anim_players: Array[AnimationPlayer]

var is_switch_1_on := false
var is_switch_2_on := false
var is_switch_3_on := false
var is_switch_4_on := false

var can_flip_switch_1 := false
var can_flip_switch_2 := false
var can_flip_switch_3 := false
var can_flip_switch_4 := false

var doors_opened := false
var can_interact_with_doors := false

var last_mouse_pos: Vector2

func _ready() -> void:
	_setup_switches()
	
	GameState.pc_power_off.connect(func():
		is_switch_3_on = false
		is_switch_1_on = false
		switch_1_flip.emit(is_switch_1_on)
		switches_anim_players[0].play("flip_switch_1_off")
		await get_tree().create_timer(0.5).timeout
		switches_anim_players[2].play("flip_switch_3_off")
	)

func _setup_switches() -> void:
	var index := 0
	
	for switch_col in switches_col:
		switch_col.mouse_entered.connect(func(): 
			_on_mouse_enter_switch_col(index)
		)
		
		switch_col.mouse_exited.connect(func():
			_on_mouse_exit_switch_col(index)
		)

		index += 1

	flip_switch_1()
	flip_switch_2()
	flip_switch_3()
	flip_switch_4()

func _on_mouse_enter_switch_col(index: int) -> void:
	if index == 0:
		can_flip_switch_1 = true
	elif index == 1:
		can_flip_switch_2 = true
	elif index == 2:
		can_flip_switch_3 = true
	elif index == 3:
		can_flip_switch_4 = true

	can_interact_with_doors = false
	player.show_generic_label("Click to flip", last_mouse_pos)
	
func _on_mouse_exit_switch_col(index: int) -> void:
	if index == 0:
		can_flip_switch_1 = false
	elif index == 1:
		can_flip_switch_2 = false
	elif index == 2:
		can_flip_switch_3 = false
	elif index == 3:
		can_flip_switch_4 = false

	player.hide_generic_label()

func _input(event: InputEvent) -> void:
	if in_interaction and event is InputEventMouseMotion:
		last_mouse_pos = event.global_position

func _process(delta: float) -> void:
	super._process(delta)
	if not in_interaction:
		return
	if Input.is_action_just_pressed("place_or_pickup"):
		_toggle_doors()
		_flip_switches()

func _flip_switches() -> void:
	if can_flip_switch_1:
		flip_switch_1()
	elif can_flip_switch_2:
		flip_switch_2()
	elif can_flip_switch_3:
		flip_switch_3()
	elif can_flip_switch_4:
		flip_switch_4()
		
func flip_switch_1() -> void:
	if is_switch_1_on:
		is_switch_1_on = false
		switches_anim_players[0].play("flip_switch_1_off")
	elif not is_switch_1_on:
		switches_anim_players[0].play("flip_switch_1_on")
		is_switch_1_on = true
	switch_1_flip.emit(is_switch_1_on)
	
func flip_switch_2() -> void:
	if is_switch_2_on:
		is_switch_2_on = false
		switches_anim_players[1].play("flip_switch_2_off")
	elif not is_switch_2_on:
		is_switch_2_on = true
		switches_anim_players[1].play("flip_switch_2_on")
	switch_2_flip.emit(is_switch_2_on)
	
func flip_switch_3() -> void:
	if is_switch_3_on:
		is_switch_3_on = false
		switches_anim_players[2].play("flip_switch_3_off")
	elif not is_switch_3_on:
		is_switch_3_on = true
		switches_anim_players[2].play("flip_switch_3_on")
		GameState.power_back_on.emit()
	switch_3_flip.emit(is_switch_3_on)
	
func flip_switch_4() -> void:
	if is_switch_4_on:
		is_switch_4_on = false
		switches_anim_players[3].play("flip_switch_4_off")
	elif not is_switch_4_on:
		is_switch_4_on = true
		switches_anim_players[3].play("flip_switch_4_on")
	switch_4_flip.emit(is_switch_4_on)

func _open_doors() -> void:
	$OpenSound.play()
	animation_player.play("open")
	doors_opened = true
	
	player.hide_generic_label()

func _close_doors() -> void:
	$CloseSound.play()
	animation_player.play("close")
	doors_opened = false
	
	player.hide_generic_label()

func _toggle_doors() -> void:
	if can_interact_with_doors:
		if doors_opened:
			_close_doors()
		else:
			_open_doors()
		
func _on_interact() -> void:
	can_interact_with_doors = true
	player.show_generic_label("Click to open", Vector2.ZERO)

func _on_static_body_3d_mouse_entered() -> void:
	if in_interaction:
		can_interact_with_doors = true
		player.show_generic_label("Click to open" if not doors_opened else "Click to close", last_mouse_pos)

func _on_static_body_3d_mouse_exited() -> void:
	if in_interaction:
		can_interact_with_doors = false
		player.hide_generic_label()


func _on_close_breaker_timer_timeout() -> void:
	pass # Replace with function body.
