extends Area3D

var door_base: RigidBody3D
@export var door_joint: HingeJoint3D
@export var unlockable: bool = true

@onready var handle_sound: AudioStreamPlayer3D = $HandleSound
@onready var door_creak_sound: AudioStreamPlayer3D = $"../DoorCreakSound"

var door_closed_rotation: float
var door_locked: bool = true
var handle_tween: Tween

var last_door_rotation_y: float = 0.0
var door_is_moving: bool = false
var creak_played_for_current_move: bool = false
var still_time: float = 0.0

var rotation_start_threshold: float = 0.006
var rotation_stop_threshold: float = 0.001
var time_before_reset: float = 0.35

func _ready() -> void:
	door_base = get_parent()
	door_closed_rotation = door_base.rotation_degrees.y
	last_door_rotation_y = door_base.rotation.y

func _process(delta: float) -> void:
	check_door_rotation_sound(delta)

func interact() -> void:
	handle_anim()
	
	if handle_sound != null:
		handle_sound.pitch_scale = randf_range(0.95, 1.05)
		handle_sound.play()

	if(door_locked and unlockable):
		unlock_door()

func unlock_door() -> void:
	print("unlocking_door")
	door_base.rotation_degrees.y = door_closed_rotation
	door_base.axis_lock_angular_x = false
	door_base.axis_lock_angular_z = false
	door_locked = false
	door_joint.set_deferred("angular_limit/lower", deg_to_rad(-150.0))

func check_door_rotation_sound(delta: float) -> void:
	if door_locked:
		last_door_rotation_y = door_base.rotation.y
		return

	var rotation_difference: float = abs(angle_difference(last_door_rotation_y, door_base.rotation.y))

	if rotation_difference > rotation_start_threshold:
		door_is_moving = true
		still_time = 0.0

		if not creak_played_for_current_move:
			play_door_creak()
			creak_played_for_current_move = true

	elif rotation_difference < rotation_stop_threshold:
		if door_is_moving:
			still_time += delta

			if still_time >= time_before_reset:
				door_is_moving = false
				creak_played_for_current_move = false
				still_time = 0.0

	last_door_rotation_y = door_base.rotation.y

func play_door_creak() -> void:
	if door_creak_sound == null:
		return

	door_creak_sound.pitch_scale = randf_range(0.95, 1.05)
	door_creak_sound.play()

func handle_anim() -> void:
	if(handle_tween):
		handle_tween.kill()
	handle_tween = create_tween()
	handle_tween.tween_property(self, "rotation", Vector3(deg_to_rad(25), rotation.y, rotation.z), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	handle_tween.tween_property(self, "rotation", Vector3(deg_to_rad(0), rotation.y, rotation.z), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	handle_tween.play()
