extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var interact_handler: Node3D

func _ready() -> void:
	interact_handler = get_tree().get_first_node_in_group("InteractHandler")

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("D", "A", "S", "W")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and not interact_handler.is_rotating_object:
		velocity.x = direction.x * SPEED * delta * 100
		velocity.z = direction.z * SPEED * delta * 100
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 100)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 100)

	move_and_slide()
