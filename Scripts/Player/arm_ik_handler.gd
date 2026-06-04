extends Node3D

var interact_handler: Node3D
var wrist_ik: Node3D
var wrist_look_at: AimModifier3D

func _ready() -> void:
	var scene_tree = get_tree()
	interact_handler = scene_tree.get_first_node_in_group("InteractHandler")
	wrist_ik = scene_tree.get_first_node_in_group("IK_Target")
	wrist_look_at = scene_tree.get_first_node_in_group("WristLookAt")


func _process(_delta: float) -> void:
	if(interact_handler.held_object):
		wrist_look_at.set_deferred("settings/0/reference_node", interact_handler.held_object)
		wrist_ik.global_position = interact_handler.held_obj_grab_point
