extends Node3D

@onready var wrist_ik_target: RigidBody3D = $WristIK_Target
@onready var elbow_ik_target: Node3D = $ElbowIK_Target
@onready var wrist_look_at_target: Node3D = $WristLookAt_Target
@onready var arm_mesh: MeshInstance3D = $Armature/Arm_Mesh

const WRIST_IK_FORCE = 15.0
const DEBUG_AXIS_LENGTH = 0.2
@onready var elbow_01: BoneAttachment3D = $Armature/Elbow01
@onready var twist_02: BoneAttachment3D = $Armature/Twist02
@onready var wrist_03: BoneAttachment3D = $Armature/Wrist03

@export var wrist_ik: RigidBody3D
@export var wrist_look_at: Node3D
@export var default_offset_mult: float = 1.0
@export var grinder_offset_mult: float = 0.4
var offset_mult: float = default_offset_mult
@export var debug_twist_bone: bool = true

@onready var armature: Skeleton3D = $Armature

var interact_handler: Node3D
var _bone_debug_mesh: MeshInstance3D
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
	if debug_twist_bone:
		wrist_ik_target.find_child("MeshInstance3D").visible = true
		wrist_ik_target.find_child("MeshInstance3D").visible = true
		wrist_ik_target.find_child("MeshInstance3D").visible = true
		arm_mesh.transparency = 0.7
		_setup_bone_debug_mesh()

func _process(_delta: float) -> void:
	var held = get_held_object()
	if held:
		update_holding(held)
	elif holding:
		reset_hands()
	if debug_twist_bone:
		_draw_twist_bone_debug()

func _physics_process(_delta: float) -> void:
	if not holding:
		sync_wrist_ik_to_arm()
		return
	var held = get_held_object()
	if not held:
		return
	wrist_ik.freeze = false
	var target = get_ik_target(get_grab_point(held))
	wrist_ik.linear_velocity = (target - wrist_ik.global_position) * WRIST_IK_FORCE
	align_wrist_ik_to_cyan()

func get_held_object() -> Node3D:
	if interact_handler.held_object:
		return interact_handler.held_object
	offset_mult = grinder_offset_mult
	return interact_handler.grabbed_grinder

func get_grab_point(obj: Node3D) -> Vector3:
	var from = interact_handler.global_position
	var to: Vector3
	var obj_gp = obj.find_child("GrabPointMark")
	if not obj.is_in_group("Rotatable") and obj_gp:
		to = obj_gp.global_position
	else:
		to = obj.global_position
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

func get_cyan_axis() -> Vector3:
	return twist_02.global_position - elbow_01.global_position

func get_ik_target(grab_point: Vector3) -> Vector3:
	var cyan = get_cyan_axis()
	if cyan.length_squared() < 0.0001:
		return grab_point
	return grab_point - cyan.normalized() * cyan.length() * offset_mult

func align_wrist_ik_to_cyan() -> void:
	var cyan = get_cyan_axis()
	if cyan.length_squared() < 0.0001:
		return
	var dir = cyan.normalized()
	var up = Vector3.UP if abs(dir.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	wrist_ik.angular_velocity = Vector3.ZERO
	wrist_ik.look_at(wrist_ik.global_position + dir, up)

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
	align_wrist_ik_to_cyan()

func reset_hands() -> void:
	holding = false
	offset_mult = default_offset_mult
	if look_at_tween:
		look_at_tween.kill()
	if reset_tween:
		reset_tween.kill()

	reset_tween = create_tween().set_parallel(true)
	reset_tween.tween_property(wrist_look_at, "position", default_pos_lookat, 0.5).set_trans(Tween.TRANS_QUAD)
	reset_tween.tween_property(wrist_ik, "position", default_pos_ik, 0.5).set_trans(Tween.TRANS_QUAD)
	reset_tween.tween_callback(sync_wrist_ik_to_arm).set_delay(0.5)

func _setup_bone_debug_mesh() -> void:
	_bone_debug_mesh = MeshInstance3D.new()
	_bone_debug_mesh.name = "TwistBoneDebug"
	armature.add_child(_bone_debug_mesh)
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	_bone_debug_mesh.material_override = material

func _draw_twist_bone_debug() -> void:
	var twist_pose = twist_02.transform
	var twist_origin = twist_pose.origin
	var elbow_origin = elbow_01.transform.origin
	var wrist_origin = wrist_03.transform.origin

	var immediate = ImmediateMesh.new()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)
	_add_debug_line(immediate, twist_origin, twist_origin + twist_pose.basis.x * DEBUG_AXIS_LENGTH, Color.RED)
	_add_debug_line(immediate, twist_origin, twist_origin + twist_pose.basis.y * DEBUG_AXIS_LENGTH, Color.GREEN)
	_add_debug_line(immediate, twist_origin, twist_origin + twist_pose.basis.z * DEBUG_AXIS_LENGTH, Color.BLUE)
	_add_debug_line(immediate, twist_origin, wrist_origin, Color.YELLOW)
	_add_debug_line(immediate, elbow_origin, twist_origin, Color.CYAN)
	immediate.surface_end()
	_bone_debug_mesh.mesh = immediate

func _add_debug_line(mesh: ImmediateMesh, from: Vector3, to: Vector3, color: Color) -> void:
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(from)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(to)
