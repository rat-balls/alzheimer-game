extends TextureRect

var interact_handler: Node

const HOLD_HAND_ICON = preload("uid://qhns457xooh2")
const INTERACT_HAND_ICON = preload("uid://b2y7mpbrcmiqi")
const OPEN_HAND_ICON = preload("uid://okh1ikorqos7")
const RETICLE_ICON = preload("uid://cemueeiiwuruf")
const GRAB_HAND = preload("uid://bknu03oynqw6a")
const HOLD_HAND = preload("uid://w6dhxh35rgdn")

func _ready() -> void:
	interact_handler = get_tree().get_first_node_in_group("InteractHandler")

func _process(_delta: float) -> void:
	if(interact_handler):
		if(interact_handler.held_object != null):
			texture = HOLD_HAND
		elif(interact_handler.valid_interact_target != null):
			texture = INTERACT_HAND_ICON
		elif(interact_handler.valid_hold_target != null):
			texture = GRAB_HAND
		else:
			texture = RETICLE_ICON
