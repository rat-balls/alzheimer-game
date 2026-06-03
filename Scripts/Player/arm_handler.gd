extends Node3D

var interact_handler: Node3D
var wrist_ik: BoneAttachment3D

func _ready() -> void:
	var scene_tree = get_tree()
	interact_handler = scene_tree.get_first_node_in_group("InteractHandler")
	wrist_ik = scene_tree.get_first_node_in_group("WristBone")

func _process(_delta: float) -> void:
	if(interact_handler.held_object):
		wrist_ik.transform = interact_handler.held_object.transform
