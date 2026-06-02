extends Camera3D

const SENSITIVITY = 0.003
const INTERACT_DISTANCE = 5.0
const HOLD_FORCE = 15.0
const THROW_FORCE = 6.0
const OBJECT_ROTATE_SENSITIVITY = 0.01
const MIN_HOLD_DISTANCE = 1.0
const MAX_HOLD_DISTANCE = 5.0
const SCROLL_SPEED = 0.3

var hold_distance: float = 2.0
var player: CharacterBody3D
var valid_hold_target: RigidBody3D = null
var held_object: RigidBody3D = null
var is_rotating_object: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player = get_parent()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ESC"):
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Prevent camera from rotating in menu
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if held_object and is_rotating_object:
			rotate_held_object(event.relative)
		else:
			rotation.x -= event.relative.y * SENSITIVITY
			#Prevent camera from rotating verticaly
			rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(80)) 
			player.rotation.y -= event.relative.x * SENSITIVITY
	if event.is_action_pressed("interact"):
		if held_object:
			drop_object()
		else: 
			try_grab_object()
	if event.is_action_pressed("throw") and held_object:
		throw_object()
	if event.is_action_pressed("rotate_object") and held_object:
		is_rotating_object = true
	if event.is_action_released("rotate_object"):
		is_rotating_object = false
	if event.is_action_pressed("wheel_up"):
		hold_distance = clamp(hold_distance + SCROLL_SPEED,MIN_HOLD_DISTANCE,MAX_HOLD_DISTANCE)
	if event.is_action_pressed("wheel_down"):
		hold_distance = clamp(hold_distance - SCROLL_SPEED,MIN_HOLD_DISTANCE,MAX_HOLD_DISTANCE)
func rotate_held_object(mouse_delta: Vector2) -> void:
	held_object.angular_velocity = Vector3.ZERO
	var rotate_y = -mouse_delta.x * OBJECT_ROTATE_SENSITIVITY
	var rotate_x = -mouse_delta.y * OBJECT_ROTATE_SENSITIVITY
	held_object.rotate_object_local(Vector3.UP, rotate_y)
	held_object.rotate_object_local(Vector3.RIGHT, rotate_x)

func throw_object() -> void:
	var obj = held_object
	drop_object()
	obj.apply_central_impulse(-global_transform.basis.z * THROW_FORCE)    
			
func drop_object() -> void:
	held_object.gravity_scale = 1.0
	held_object.angular_damp = 0.05
	held_object.linear_damp = 0.05
	held_object = null

func find_valid_grab_target() -> void:
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = global_position + -global_transform.basis.z * INTERACT_DISTANCE
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		valid_hold_target = null
		return
	
	if result["collider"] is RigidBody3D and result["collider"].is_in_group("interactable"):
		valid_hold_target = result["collider"]
	else:
		valid_hold_target = null

func try_grab_object() -> void:
	if valid_hold_target != null:
		print("name:", valid_hold_target.name, "type:",valid_hold_target.get_class())
		held_object = valid_hold_target
		held_object.gravity_scale = 0.0
		held_object.linear_damp = 6.0
		held_object.angular_damp = 6.0
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	find_valid_grab_target()

func _physics_process(delta: float) -> void:
	if held_object:
		var taget_position = global_position + -global_transform.basis.z * hold_distance
		var direction = taget_position - held_object.global_position
		held_object.linear_velocity = direction * HOLD_FORCE
