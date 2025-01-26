extends StaticBody3D

class_name Pickable

const placeholder_mat = preload("res://assets/materials/placeholder_mat.tres")

@export
var id: String = ""

@export
var is_placeholder := false

var player: Player = null

var current_mouse_pos: Vector2

var is_picked := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		current_mouse_pos = event.position

func setup(player: Player) -> void:
	self.player = player
	
	if is_placeholder:
		visible = false

func _ready() -> void:
	assert(id != "", name + " needs proper ID")
	
	collision_layer = 2

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if is_placeholder:
		for child in get_children():
			if child is MeshInstance3D:
				var mesh_instance: MeshInstance3D = child
				mesh_instance.material_override = placeholder_mat

func init_pickable() -> void:
	if is_placeholder:
		for child in get_children():
			if child is MeshInstance3D:
				var mesh_instance: MeshInstance3D = child
				mesh_instance.material_override = placeholder_mat

func _on_mouse_entered() -> void:
	if is_picked:
		return
	if is_placeholder and player.picked_object != null and player.picked_object.id == id:
		player.show_place_object_label(current_mouse_pos, self)
	elif is_placeholder and player.picked_object == null or (player.picked_object != null and player.picked_object.id != id):
		player.show_missing_object_label(current_mouse_pos)
	elif not is_placeholder and player.picked_object == null:
		player.show_pickup_object_label(current_mouse_pos, self)

func _on_mouse_exited() -> void:
	if is_picked:
		return
	player.hide_all_labels()
	
func pickup() -> void:
	is_placeholder = true
	for child in get_children():
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child
			mesh_instance.material_override = placeholder_mat

func place() -> void:
	is_picked = false
	is_placeholder = false
	visible = true
	for child in get_children():
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child
			mesh_instance.material_override = null
