extends Node

@onready var map_sky_box: Node3D = $MapSkyBox
@export var rotation_speed: float = 13.58  # Degrees per second

@export var lights: Array[Node]
@export var min_energy: float = 0.2
@export var max_energy: float = 1.5
@export var duration: float = 2.0

func _process(delta):
	map_sky_box.rotation_degrees.y += rotation_speed * delta  # Rotate on Y-axis (for 3D)
	
	# If rotation reaches or exceeds 360 degrees, reset to 0
	if map_sky_box.rotation_degrees.y >= 360:
		map_sky_box.rotation_degrees.y = 0

func _ready():
	for light in lights:
		if light is OmniLight3D or light is SpotLight3D or light is DirectionalLight3D or light is Light2D:
			start_loop(light)  # Start animation loop for each light

func start_loop(light):
	var tween = get_tree().create_tween()  # Create a new Tween each time

	tween.tween_property(light, "light_energy" if light is Light3D else "energy", max_energy, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(light, "light_energy" if light is Light3D else "energy", min_energy, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(func(): start_loop(light))  # Restart the loop with a NEW tween
