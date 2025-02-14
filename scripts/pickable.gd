extends StaticBody3D

class_name Pickable

const placeholder_mat = preload("res://assets/materials/placeholder_mat.tres")
const outline_mat = preload("res://assets/materials/new_outline_mat.tres")

@export
var id: String = ""

@export
var is_placeholder := false

var player: Player = null

var current_mouse_pos: Vector2

var is_picked := false

var current_interactable: Interactable = null

var visual_instance_3D: MeshInstance3D = null

signal placed

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		current_mouse_pos = event.position

func setup(player: Player, interactable: Interactable) -> void:
	self.player = player
	current_interactable = interactable
	
	if is_placeholder:
		visible = false

func _ready() -> void:
	assert(id != "", name + " needs proper ID")
	
	collision_layer = 2

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	find_visual_instance_3D()

	if is_placeholder:
		visual_instance_3D.material_override = placeholder_mat

func find_visual_instance_3D() -> void:
	for child in get_children():
		if child is VisualInstance3D:
			visual_instance_3D = child
			break

func init_pickable() -> void:
	if is_placeholder:
		visual_instance_3D.material_override = placeholder_mat

func _on_mouse_entered() -> void:
	if is_picked:
		return
	if is_placeholder and player.picked_object != null and player.picked_object.id == id:
		player.show_place_object_label(current_mouse_pos, self)
	elif is_placeholder and player.picked_object == null or (player.picked_object != null and player.picked_object.id != id):
		player.show_missing_object_label(current_mouse_pos)
	elif not is_placeholder and player.picked_object == null and current_interactable.in_interaction:
		show_outline()
		player.show_pickup_object_label(current_mouse_pos, self)

func _on_mouse_exited() -> void:
	if is_picked:
		return
	player.hide_all_labels()
	hide_outline()
	
func pickup() -> void:
	is_placeholder = true
	visual_instance_3D.material_override = placeholder_mat
	_on_picked_up()

func _on_picked_up() -> void:
	pass

func place() -> void:
	is_picked = false
	is_placeholder = false
	visible = true
	switch_to_rendering_layer(1)
	visual_instance_3D.material_override = null
	placed.emit()
	_on_placed()

func _on_placed() -> void:
	pass

func switch_to_rendering_layer(layer: int) -> void:
	visual_instance_3D.layers = layer

func show_outline() -> void:
	var current_mat = visual_instance_3D.get_active_material(0).duplicate()
	current_mat.next_pass = outline_mat
	visual_instance_3D.set_surface_override_material(0, current_mat)

func hide_outline() -> void:
	visual_instance_3D.set_surface_override_material(0, null)

func disable_collisions() -> void:
	recursively_disable_all_collision_shapes(self)

func recursively_disable_all_collision_shapes(child: Node3D) -> void:
	if child is CollisionShape3D:
		child.disabled = true
	for c in child.get_children():
		if c is Node3D:
			recursively_disable_all_collision_shapes(c)
