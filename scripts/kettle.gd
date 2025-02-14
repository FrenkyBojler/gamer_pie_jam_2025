extends Pickable

class_name Kettle

var is_boiled := false

var boil_timer := Timer.new()
var cooldown_timer := Timer.new()

func _ready() -> void:
    super._ready()

    add_child(boil_timer)
    boil_timer.wait_time = 5.0
    boil_timer.one_shot = true
    boil_timer.autostart = false

    boil_timer.timeout.connect(func():
        is_boiled = true
    )

    add_child(cooldown_timer)
    cooldown_timer.wait_time = 0.1
    cooldown_timer.one_shot = true
    cooldown_timer.autostart = false

    cooldown_timer.timeout.connect(func():
        pass
    )


func _on_picked_up() -> void:
    if not is_boiled:
        boil_timer.paused = true
        cooldown_timer.start()
