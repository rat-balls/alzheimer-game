extends Camera3D

const SENSITIVITY = 0.003
const INTERACT_DISTANCE = 5.0
const HOLD_DISTANCE = 2.0
const HOLD_FORCE = 15.0
const THROW_FORCE = 6.0

var player: CharacterBody3D
var held_object: RigidBody3D = null

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
        
func throw_object() -> void:
    var obj = held_object
    drop_object()
    obj.apply_central_impulse(-global_transform.basis.z * THROW_FORCE)    
            
func drop_object() -> void:
    held_object.gravity_scale = 1.0
    held_object.angular_damp = 0.0
    held_object.linear_damp = 0.0
    held_object = null
    
func try_grab_object() -> void:
    var space_state = get_world_3d().direct_space_state
    var from = global_position
    var to = global_position + -global_transform.basis.z * INTERACT_DISTANCE
    var query = PhysicsRayQueryParameters3D.create(from, to)
    var result = space_state.intersect_ray(query)
    if result.is_empty():
        return
    var obj = result["collider"]
    print("name:", obj.name, "type:",obj.get_class())
    if obj is RigidBody3D and obj.is_in_group("interactable"):
        held_object = obj
        held_object.gravity_scale = 0.0
        held_object.linear_damp = 6.0
        held_object.angular_damp = 6.0
        
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
func _physics_process(delta: float) -> void:
    if held_object:
        var taget_position = global_position + -global_transform.basis.z * HOLD_DISTANCE
        var direction = taget_position - held_object.global_position
        held_object.linear_velocity = direction * HOLD_FORCE
