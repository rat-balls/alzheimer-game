extends Node3D

var interact_handler: Node3D
var wrist_ik: Node3D
var wrist_look_at: Node3D
var grinder_hand_dest: Marker3D
var default_pos: Vector3

func _ready() -> void:
	var scene_tree = get_tree()
	interact_handler = scene_tree.get_first_node_in_group("InteractHandler")
	wrist_ik = scene_tree.get_first_node_in_group("IK_Target")
	wrist_look_at = scene_tree.get_first_node_in_group("LookAt_Target")
	grinder_hand_dest = scene_tree.get_first_node_in_group("GrinderHandDest")
	default_pos = wrist_ik.position

func _process(_delta: float) -> void:
	if(interact_handler.held_object):
		wrist_look_at.global_position = interact_handler.held_object.global_position
		wrist_ik.global_position = interact_handler.held_obj_grab_point
	elif(interact_handler.grabbed_grinder):
		wrist_look_at.global_position = grinder_hand_dest.global_position + Vector3.DOWN * 0.1
		wrist_ik.global_position = grinder_hand_dest.global_position
	else:
		wrist_look_at.position = default_pos
		wrist_ik.position = default_pos
