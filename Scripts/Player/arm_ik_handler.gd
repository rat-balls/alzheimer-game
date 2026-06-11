extends Node3D

const WRIST_IK_FORCE = 15.0

@export var wrist_ik: RigidBody3D
@export var wrist_look_at: Node3D

var interact_handler: Node3D
var default_pos_ik: Vector3
var default_pos_lookat: Vector3
var holding: bool = false
var look_at_tween: Tween
var reset_tween: Tween

func _ready() -> void:
	interact_handler = get_tree().get_first_node_in_group("InteractHandler")
	default_pos_ik = wrist_ik.position
	default_pos_lookat = wrist_look_at.position
	wrist_ik.linear_damp = 6.0
	sync_wrist_ik_to_arm()

func _process(_delta: float) -> void:
	var held = get_held_object()
	if held:
		update_holding(held)
	elif holding:
		reset_hands()

func _physics_process(_delta: float) -> void:
	if not holding:
		sync_wrist_ik_to_arm()
		return
	var held = get_held_object()
	if not held:
		return
	wrist_ik.freeze = false
	var target = get_grab_point(held)
	wrist_ik.linear_velocity = (target - wrist_ik.global_position) * WRIST_IK_FORCE

func get_held_object() -> Node3D:
	if interact_handler.held_object:
		return interact_handler.held_object
	return interact_handler.grabbed_grinder

func get_grab_point(obj: Node3D) -> Vector3:
	var from = interact_handler.global_position
	var to = obj.global_position if obj.is_in_group("Rotatable") else obj.find_child("GrabPointMark").global_position
	var ray = to - from
	var ray_length = ray.length()
	if ray_length < 0.01:
		return to

	var query = PhysicsRayQueryParameters3D.create(from, from + ray / ray_length * (ray_length + 1.0))
	query.collide_with_bodies = true
	query.exclude = [wrist_ik.get_rid(), interact_handler.player.get_rid()]

	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and (hit.collider == obj or (hit.collider is Node and obj.is_ancestor_of(hit.collider))):
		return hit.position
	return from.lerp(to, 0.9)

func update_holding(obj: Node3D) -> void:
	if not obj.find_child("GrabPointMark"):
		return

	var look_at_mark = obj.find_child("LookAtMark")
	if not holding:
		holding = true
		wrist_ik.freeze = false
		if look_at_tween:
			look_at_tween.kill()
		if look_at_mark:
			look_at_tween = create_tween()
			look_at_tween.tween_property(wrist_look_at, "global_position", look_at_mark.global_position, 0.3).set_trans(Tween.TRANS_QUAD)
		return

	if look_at_mark:
		wrist_look_at.global_position = look_at_mark.global_position

func sync_wrist_ik_to_arm() -> void:
	wrist_ik.freeze = true
	wrist_ik.linear_velocity = Vector3.ZERO
	wrist_ik.angular_velocity = Vector3.ZERO
	wrist_ik.position = default_pos_ik

func reset_hands() -> void:
	holding = false
	if look_at_tween:
		look_at_tween.kill()
	if reset_tween:
		reset_tween.kill()

	reset_tween = create_tween().set_parallel(true)
	reset_tween.tween_property(wrist_look_at, "position", default_pos_lookat, 0.5).set_trans(Tween.TRANS_QUAD)
	reset_tween.tween_property(wrist_ik, "position", default_pos_ik, 0.5).set_trans(Tween.TRANS_QUAD)
	reset_tween.tween_callback(sync_wrist_ik_to_arm).set_delay(0.5)
