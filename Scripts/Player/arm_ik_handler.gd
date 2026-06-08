extends Node3D

@export var wrist_ik: Node3D
@export var wrist_look_at: Node3D
@export var armature: Skeleton3D

var ik_tween: Tween
var default_tween: Tween

var arm_bone_idx: int
var forearm_bone_idx: int

var interact_handler: Node3D
var default_pos_ik: Vector3
var default_pos_lookat: Vector3

var holding: bool = false
var animating: bool = false

func _ready() -> void:
	var scene_tree = get_tree()
	interact_handler = scene_tree.get_first_node_in_group("InteractHandler")
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
		if(holding):
			reset_hands()


func reset_hands():
	holding = false
	if(default_tween): default_tween.kill()
	
	default_tween = create_tween()
	default_tween.set_parallel(true)
	default_tween.tween_property(wrist_look_at, "position", default_pos_lookat, 0.5).set_trans(Tween.TRANS_QUAD)
	default_tween.tween_property(wrist_ik, "position", default_pos_ik, 0.5).set_trans(Tween.TRANS_QUAD)
	armature.set_bone_pose_scale(arm_bone_idx, Vector3(1, 1, 1))
	armature.set_bone_pose_scale(forearm_bone_idx, Vector3(1, 1, 1))

func handle_held_obj(obj) ->void:
	
	var obj_gp = obj.find_child("GrabPointMark")
	var obj_la = obj.find_child("LookAtMark")
	if(obj_gp):
		if(!holding and !animating): 
			animating = true
			holding = true
			if(ik_tween): ik_tween.kill()
			
			ik_tween = create_tween()
			ik_tween.set_parallel(true)
			ik_tween.tween_property(wrist_look_at, "global_position", obj_la.global_position, 0.5).set_trans(Tween.TRANS_QUAD)
			ik_tween.tween_property(wrist_ik, "global_position", obj_gp.global_position, 0.5).set_trans(Tween.TRANS_QUAD)
			
			#ik_tween.tween_method({() => animating = false})
			
		else:
			print("here")
			wrist_look_at.global_position = obj_la.global_position
			wrist_ik.global_position = obj_gp.global_position
			armature.set_bone_pose_scale(arm_bone_idx, Vector3(1, clamp(armature.global_position.distance_to(obj_gp.global_position) * 0.47, 0.6, 1.), 1))
			armature.set_bone_pose_scale(forearm_bone_idx, Vector3(1, clamp(armature.global_position.distance_to(obj_gp.global_position) * 0.47, 0.6, 1), 1))
