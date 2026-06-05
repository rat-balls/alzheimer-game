extends Node3D

@export var wrist_ik: Node3D
@export var wrist_look_at: Node3D
@export var armature: Skeleton3D

var arm_bone_idx: int
var forearm_bone_idx: int

var interact_handler: Node3D
var grinder_hand_dest: Marker3D
var default_pos: Vector3

func _ready() -> void:
	var scene_tree = get_tree()
	interact_handler = scene_tree.get_first_node_in_group("InteractHandler")
	grinder_hand_dest = scene_tree.get_first_node_in_group("GrinderHandDest")
	default_pos = wrist_ik.position
	
	arm_bone_idx = armature.find_bone("Arm")
	forearm_bone_idx = armature.find_bone("Forearm")

func _process(_delta: float) -> void:
	if(interact_handler.held_object):
		var held_obj_pos = interact_handler.held_object.global_position
		var held_obj_gp = interact_handler.held_obj_grab_point
		wrist_look_at.global_position = held_obj_pos + armature.global_position.direction_to(held_obj_pos)
		if(held_obj_gp.distance_to(held_obj_pos) < 0.1):
			wrist_ik.global_position = held_obj_gp
		else:
			wrist_ik.global_position = held_obj_pos
		armature.set_bone_pose_scale(arm_bone_idx, Vector3(1, armature.global_position.distance_to(wrist_ik.global_position) * 0.3, 1))
		armature.set_bone_pose_scale(forearm_bone_idx, Vector3(1, armature.global_position.distance_to(wrist_ik.global_position) * 0.3, 1))
	elif(interact_handler.grabbed_grinder):
		wrist_look_at.global_position = grinder_hand_dest.global_position + Vector3.DOWN 
		wrist_ik.global_position = grinder_hand_dest.global_position
	else:
		wrist_look_at.position = default_pos
		wrist_ik.position = default_pos
		armature.set_bone_pose_scale(arm_bone_idx, Vector3(1, 1, 1))
		armature.set_bone_pose_scale(forearm_bone_idx, Vector3(1, 1, 1))
