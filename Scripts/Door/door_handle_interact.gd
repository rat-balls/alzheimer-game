extends Area3D

var door_base: RigidBody3D
@export var door_joint: HingeJoint3D
@export var unlockable: bool = true
var door_closed_rotation: float
var door_locked: bool = true
var handle_tween: Tween

func _ready() -> void:
	door_base = get_parent()
	door_closed_rotation = door_base.rotation_degrees.y

func interact() -> void:
	handle_anim()
	if(door_locked and unlockable):
		unlock_door()


func unlock_door() -> void:
	print("unlocking_door")
	door_base.rotation_degrees.y = door_closed_rotation
	door_base.axis_lock_angular_x = false
	door_base.axis_lock_angular_z = false
	door_locked = false
	door_joint.set_deferred("angular_limit/lower", deg_to_rad(-150.0))

func handle_anim() -> void:
	if(handle_tween):
		handle_tween.kill()
	handle_tween = create_tween()
	handle_tween.tween_property(self, "rotation", Vector3(deg_to_rad(25), rotation.y, rotation.z), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	handle_tween.tween_property(self, "rotation", Vector3(deg_to_rad(0), rotation.y, rotation.z), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	handle_tween.play()
