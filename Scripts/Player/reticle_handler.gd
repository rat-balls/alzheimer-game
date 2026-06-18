extends TextureRect

var interact_handler: Node

const RETICLE_ICON = preload("uid://cemueeiiwuruf")
const FINAL_GRAB = preload("uid://bf81dph7yeeoq")
const FINAL_INTERACT = preload("uid://djrunetac7dsi")
const FINAL_OPEN = preload("uid://dpd6e3agpwcsb")

func _ready() -> void:
	interact_handler = get_tree().get_first_node_in_group("InteractHandler")

func _process(_delta: float) -> void:
	if(interact_handler):
		if(interact_handler.held_object != null):
			texture = FINAL_GRAB
		elif(interact_handler.valid_interact_target != null):
			texture = FINAL_INTERACT
		elif(interact_handler.valid_hold_target != null):
			texture = FINAL_OPEN
		else:
			texture = RETICLE_ICON
		
		if texture == RETICLE_ICON:
			print("reticle_icon")
			rotation_degrees = 0.0
			size = Vector2(64, 64)
			position = Vector2(608, 328)
			pivot_offset = Vector2(32, 32)
		else:
			print("hand_icon")
			rotation_degrees = 135
			size = Vector2(128, 256)
			position = Vector2(576, 256)
			pivot_offset = Vector2(64, 128)
