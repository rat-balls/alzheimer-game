extends Node3D

const INTERACT_DISTANCE = 5.0
const HOLD_FORCE = 15.0
const THROW_FORCE = 6.0
const OBJECT_ROTATE_SENSITIVITY = 1
const MIN_HOLD_DISTANCE = 1.0
const MAX_HOLD_DISTANCE = 5.0
const SCROLL_SPEED = 0.3

var player: CharacterBody3D
var camera: Camera3D

var default_hold_distance: float = 2.0
var hold_distance: float = default_hold_distance
var valid_hold_target: RigidBody3D = null
var valid_interact_target: Area3D = null
var held_object: RigidBody3D = null
var held_obj_grab_point: Vector3 = Vector3.ZERO
var grabbed_grinder: Node3D = null
var is_rotating_object: bool = false

func _ready() -> void:
	var scene_tree = get_tree()
	player = scene_tree.get_first_node_in_group("Player")
	camera = scene_tree.get_first_node_in_group("PlayerCamera")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	find_valid_grab_target()

func _physics_process(_delta: float) -> void:
	if held_object:
		var target_position = global_position + -global_transform.basis.z * hold_distance
		var direction = target_position - held_object.global_position
		held_object.linear_velocity = direction * HOLD_FORCE

func _input(event: InputEvent) -> void:
	if camera.mouse_visible:
		return

	if event is InputEventMouseMotion:

		if grabbed_grinder:
			grabbed_grinder.rotate_handle(event.relative)
			return

		if held_object and is_rotating_object:
			rotate_held_object(event.relative)

	if event.is_action_pressed("Interact"):

		if held_object or grabbed_grinder:
			drop_object()
		else:
			try_interact_object()

	elif event.is_action_pressed("Throw") and held_object:
		throw_object()

	elif event.is_action_pressed("RotateObject") and held_object and held_object.is_in_group("Rotatable"):
		is_rotating_object = true

	elif event.is_action_released("RotateObject"):
		is_rotating_object = false

	elif event.is_action_pressed("WHEEL_UP"):
		hold_distance = clamp(hold_distance + SCROLL_SPEED,MIN_HOLD_DISTANCE,MAX_HOLD_DISTANCE)

	elif event.is_action_pressed("WHEEL_DOWN"):
		hold_distance = clamp(hold_distance - SCROLL_SPEED,MIN_HOLD_DISTANCE,MAX_HOLD_DISTANCE)

func rotate_held_object(mouse_delta: Vector2) -> void:
	held_object.angular_velocity = Vector3.ZERO
	var obj_rotate_y = -mouse_delta.x * OBJECT_ROTATE_SENSITIVITY
	var obj_rotate_x = -mouse_delta.y * OBJECT_ROTATE_SENSITIVITY
	held_object.rotate_object_local(Vector3.UP, obj_rotate_y)
	held_object.rotate_object_local(Vector3.RIGHT, obj_rotate_x)

func throw_object() -> void:
	var obj = held_object
	drop_object()
	obj.apply_central_impulse(-global_transform.basis.z * THROW_FORCE)    

func drop_object() -> void:
	if grabbed_grinder:
		grabbed_grinder.stop_grabbing_handle()
		grabbed_grinder = null
		is_rotating_object = false
		return

	if held_object:
		held_object.gravity_scale = 1.0
		held_object.angular_damp = 0.05
		held_object.linear_damp = 0.05
		held_object = null

func find_valid_grab_target() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from = global_position
	var to = global_position + -global_transform.basis.z * INTERACT_DISTANCE
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		valid_hold_target = null
		valid_interact_target = null
		return
	var obj = result["collider"]
	
	if obj is Area3D:
		valid_interact_target = obj
		valid_hold_target = null	
	elif obj is RigidBody3D:
		valid_hold_target = obj
		held_obj_grab_point = result["position"]
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
	hold_distance = default_hold_distance
	held_object = valid_hold_target
	held_object.gravity_scale = 0.0
	held_object.linear_damp = 6.0
	held_object.angular_damp = 6.0

func interact() -> void:
	print("name:", valid_interact_target.name, "type:", valid_interact_target.get_class())
	if valid_interact_target.is_in_group("GrinderHandle"):
		grabbed_grinder = valid_interact_target.grinder
		is_rotating_object = true
	valid_interact_target.interact()
