extends Node3D

@onready var door_base: RigidBody3D = $Door_base
@onready var handle_base: Node3D = $Door_base/Handle_base

var handle_pressed: bool= false
var handle_rotation: float = 0.0
var handle_unlocked: bool = false

func activate_handle() -> void:
	handle_pressed = true

func _process(delta: float) -> void:
	var target_rotation : float = -35.0 if handle_pressed else 0.0

	handle_rotation = lerp(handle_rotation, target_rotation, delta * 10.0)
	handle_base.rotation_degrees.x = handle_rotation

	if handle_rotation <= -30.0:
		handle_unlocked = true
	else:
		handle_unlocked = false

	if handle_pressed and abs(handle_rotation - target_rotation) < 1.0:
		handle_pressed = false

func pull_door(camera: Camera3D, mouse_delta: Vector2) -> void:
	if not handle_unlocked:
		return

	var force : float= -mouse_delta.x * 0.08
	door_base.apply_torque_impulse(Vector3.UP * force)
