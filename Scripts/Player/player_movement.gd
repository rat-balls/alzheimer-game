extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer

var interact_handler: Node3D

var footstep_sounds: Array[AudioStream] = [
	preload("res://Assets/SFX/Footstep-1.wav"),
	preload("res://Assets/SFX/Footstep-2.wav")
]

var footstep_timer: float = 0.0
var footstep_interval: float = 0.36

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

	_handle_footsteps(delta, input_dir)

func _handle_footsteps(delta: float, input_dir: Vector2) -> void:
	if input_dir.length() > 0.1 and not interact_handler.is_rotating_object:

		if footstep_timer <= 0.0:
			_play_footstep()
			footstep_timer = footstep_interval

		footstep_timer -= delta

	else:
		footstep_timer = 0.0

func _play_footstep() -> void:
	footstep_player.stream = footstep_sounds.pick_random()

	footstep_player.pitch_scale = randf_range(0.95, 1.05)

	footstep_player.volume_db = randf_range(-16.0, -12.0)

	footstep_player.play()
