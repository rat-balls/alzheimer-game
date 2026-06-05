extends Node3D

@export var wrist_ik: Node3D
@export var wrist_look_at: Node3D
@export var armature: Skeleton3D

var arm_bone_idx: int
var forearm_bone_idx: int

var interact_handler: Node3D
var grinder_hand_dest: Marker3D
var default_pos_ik: Vector3
var default_pos_lookat: Vector3

func _ready() -> void:
	var scene_tree = get_tree()
	interact_handler = scene_tree.get_first_node_in_group("InteractHandler")
	grinder_hand_dest = scene_tree.get_first_node_in_group("GrinderHandDest")
	default_pos_ik = wrist_ik.position
	default_pos_lookat = wrist_look_at.position
	
	arm_bone_idx = armature.find_bone("Arm")
	forearm_bone_idx = armature.find_bone("Forearm")

func _process(_delta: float) -> void:
	if(interact_handler.held_object):
		handle_held_obj(interact_handler.held_object)
		
	elif(interact_handler.grabbed_grinder):
		handle_held_obj(interact_handler.grabbed_grinder)
	else:
		wrist_look_at.position = default_pos_lookat
		wrist_ik.position = default_pos_ik
		armature.set_bone_pose_scale(arm_bone_idx, Vector3(1, 1, 1))
		armature.set_bone_pose_scale(forearm_bone_idx, Vector3(1, 1, 1))

func handle_held_obj(obj) ->void:
	var obj_gp = obj.find_child("GrabPointMark")
	var obj_la = obj.find_child("LookAtMark")
	if(obj_gp):
		wrist_look_at.global_position = obj_la.global_position
		wrist_ik.global_position = obj_gp.global_position
		armature.set_bone_pose_scale(arm_bone_idx, Vector3(1, armature.global_position.distance_to(obj_gp.global_position) * 0.47, 1))
		armature.set_bone_pose_scale(forearm_bone_idx, Vector3(1, armature.global_position.distance_to(obj_gp.global_position) * 0.47, 1))
