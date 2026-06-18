extends Node3D

const INTERACT_DISTANCE = 4.0
const HOLD_FORCE = 15.0
const THROW_FORCE = 6.0
const OBJECT_ROTATE_SENSITIVITY = 2.5
const MIN_HOLD_DISTANCE = 1.5
const MAX_HOLD_DISTANCE = 2.5
const SCROLL_SPEED = 0.3

var player: CharacterBody3D
var camera: Camera3D

var default_hold_distance: float = 2.0
var hold_distance: float = default_hold_distance
var valid_hold_target: RigidBody3D = null
var valid_interact_target: Area3D = null
var held_object: RigidBody3D = null
var held_rotation_offset: Quaternion = Quaternion.IDENTITY
var grabbed_grinder: Node3D = null
var is_rotating_object: bool = false

enum InteractionState {
	Normal,
	Holding,
	Rotating
}
var curr_state: InteractionState = InteractionState.Normal
var last_state: InteractionState = curr_state
var UI: Control
var normal_keys_container: VBoxContainer
var holding_keys_container: VBoxContainer
var rotating_keys_container: VBoxContainer
var rotation_label: Label


func _ready() -> void:
	var sc_tree = get_tree()
	player = sc_tree.get_first_node_in_group("Player")
	camera = sc_tree.get_first_node_in_group("PlayerCamera")
	UI = sc_tree.get_first_node_in_group("UI")
	normal_keys_container = UI.find_child("NormalKeys")
	holding_keys_container = UI.find_child("HoldingKeys")
	rotating_keys_container = UI.find_child("RotatingKeys")
	rotation_label = holding_keys_container.find_child("Rotation")

func _process(_delta: float) -> void:
	find_valid_grab_target()
	handle_keys_display()

func handle_keys_display():
	if(curr_state != last_state):
		match curr_state:
			InteractionState.Normal:
				normal_keys_container.visible = true
				holding_keys_container.visible = false
				rotating_keys_container.visible = false
			InteractionState.Holding:
				normal_keys_container.visible = false
				holding_keys_container.visible = true
				rotating_keys_container.visible = false
				rotation_label.visible = held_object.is_in_group("Rotatable")
			InteractionState.Rotating:
				normal_keys_container.visible = false
				holding_keys_container.visible = false
				rotating_keys_container.visible = true
			_:
				last_state = InteractionState.Normal
				curr_state = InteractionState.Normal
				normal_keys_container.visible = true
				holding_keys_container.visible = false
				rotating_keys_container.visible = false

func update_state(state: InteractionState):
	last_state = curr_state
	curr_state = state

func _physics_process(delta: float) -> void:
	if not held_object:
		return

	var hold_position = global_position - global_transform.basis.z * hold_distance
	held_object.linear_velocity = (hold_position - held_object.global_position) * HOLD_FORCE
	
	#this makes the object rotate with the player when the player rotates
	if held_object.is_in_group("Rotatable"):
		var target_rotation = global_transform.basis.get_rotation_quaternion() * held_rotation_offset
		held_object.global_transform = Transform3D(Basis(target_rotation), held_object.global_position)
		held_object.angular_velocity = Vector3.ZERO
	
		if is_rotating_object:
			var input_dir := Input.get_vector("D", "A", "S", "W")

			if input_dir.length() > 0.0:
				rotate_held_object(input_dir, delta)
	
	#this make the player drop the object if it's too far (when you go far from a held foor for example)
	if held_object.global_position.distance_to(global_position) > MAX_HOLD_DISTANCE + 2:
		drop_object()
	#and this makes objects that were grabbed from far away go in front of the player at the good distance
	elif held_object.global_position.distance_to(global_position) > MAX_HOLD_DISTANCE:
		hold_distance = MAX_HOLD_DISTANCE

func _input(event: InputEvent) -> void:
	if camera.mouse_visible:
		return

	if event is InputEventMouseMotion:
		if grabbed_grinder:
			grabbed_grinder.rotate_handle(event.relative)
			return

	if event.is_action_pressed("Interact"):
		if held_object or grabbed_grinder:
			drop_object()
		else:
			try_interact_object()
	elif event.is_action_pressed("Throw") and held_object:
		throw_object()
	elif event.is_action_pressed("RotateObject") and held_object and held_object.is_in_group("Rotatable"):
		is_rotating_object = !is_rotating_object
		if(is_rotating_object):
			update_state(InteractionState.Rotating)
		else:
			update_state(InteractionState.Holding)
	elif event.is_action_pressed("WHEEL_UP"):
		hold_distance = clamp(hold_distance + SCROLL_SPEED, MIN_HOLD_DISTANCE, MAX_HOLD_DISTANCE)
	elif event.is_action_pressed("WHEEL_DOWN"):
		hold_distance = clamp(hold_distance - SCROLL_SPEED, MIN_HOLD_DISTANCE, MAX_HOLD_DISTANCE)

func rotate_held_object(input_dir: Vector2, delta: float) -> void:
	var camera_right = global_transform.basis.x.normalized()
	var camera_up = global_transform.basis.y.normalized()

	var current_rotation = global_transform.basis.get_rotation_quaternion() * held_rotation_offset

	var pitch_amount = -input_dir.y * OBJECT_ROTATE_SENSITIVITY * delta
	var yaw_amount = -input_dir.x * OBJECT_ROTATE_SENSITIVITY * delta

	var delta_rotation = (
		Quaternion(camera_right, pitch_amount) *
		Quaternion(camera_up, yaw_amount)
	)

	held_rotation_offset = (
		global_transform.basis.get_rotation_quaternion().inverse()
		* delta_rotation
		* current_rotation
	)

func throw_object() -> void:
	var obj = held_object
	drop_object()
	obj.apply_central_impulse(-global_transform.basis.z * THROW_FORCE)

func drop_object() -> void:
	update_state(InteractionState.Normal)
	is_rotating_object = false
	if grabbed_grinder:
		grabbed_grinder.stop_grabbing_handle()
		grabbed_grinder = null
		is_rotating_object = false
		return
	if not held_object:
		return
	held_object.gravity_scale = 1.0
	held_object.angular_damp = 0.05
	held_object.linear_damp = 0.05
	held_object = null
	held_rotation_offset = Quaternion.IDENTITY

func find_valid_grab_target() -> void:
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position - global_transform.basis.z * INTERACT_DISTANCE)
	query.collide_with_areas = true
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		valid_hold_target = null
		valid_interact_target = null
		return
	var obj = result.collider
	if obj is Area3D:
		valid_interact_target = obj
		valid_hold_target = null
	elif obj is RigidBody3D:
		valid_hold_target = obj
		valid_interact_target = null
	else:
		valid_hold_target = null
		valid_interact_target = null

func try_interact_object() -> void:
	if valid_hold_target:
		if valid_hold_target.has_method("interact"):
			valid_hold_target.interact()
		else:
			grab()
	if valid_interact_target:
		interact()

func grab() -> void:
	update_state(InteractionState.Holding)
	hold_distance = valid_hold_target.global_position.distance_to(global_position)
	held_object = valid_hold_target
	held_object.gravity_scale = 0.0
	held_object.linear_damp = 6.0
	held_object.angular_damp = 6.0
	held_rotation_offset = global_transform.basis.get_rotation_quaternion().inverse() * held_object.global_transform.basis.get_rotation_quaternion()

func interact() -> void:
	print("name:", valid_interact_target.name, "type:", valid_interact_target.get_class())
	if valid_interact_target.is_in_group("GrinderHandle"):
		grabbed_grinder = valid_interact_target.grinder
		is_rotating_object = true
	if valid_interact_target.has_method("interact"):
		valid_interact_target.interact()
