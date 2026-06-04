extends RigidBody3D

@export var table_position: Marker3D
@export var animation_duration :float= 1.5

var is_animating :bool= false
var is_available :bool= false

func _ready() -> void:
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	gravity_scale = 0.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func interact() -> void:
	if is_animating or is_available:
		return

	animate_to_table()

func animate_to_table() -> void:
	is_animating = true

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "global_position", table_position.global_position, animation_duration)
	tween.tween_property(self, "global_rotation", table_position.global_rotation, animation_duration)

	await tween.finished

	freeze = false
	gravity_scale = 1.0
	
	is_animating = false
	remove_from_group("AnimatedInteractable")
	is_available = true
