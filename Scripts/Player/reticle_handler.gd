extends TextureRect

var interact_handler: Node

const RETICLE_ICON = preload("uid://cemueeiiwuruf")
const FINAL_GRAB = preload("uid://bf81dph7yeeoq")
const FINAL_INTERACT = preload("uid://djrunetac7dsi")
const FINAL_OPEN = preload("uid://dpd6e3agpwcsb")
@onready var rotate_indic: Label = $"../RotateIndic"

func _ready() -> void:
	interact_handler = get_tree().get_first_node_in_group("InteractHandler")

func _process(_delta: float) -> void:
	if(interact_handler and !interact_handler.grabbed_grinder):
		if(interact_handler.held_object != null):
			if(interact_handler.is_rotating_object):
				rotate_indic.visible = true
			else:
				rotate_indic.visible = false
			texture = FINAL_GRAB
		elif(interact_handler.valid_interact_target != null):
			texture = FINAL_INTERACT
			rotate_indic.visible = false
		elif(interact_handler.valid_hold_target != null):
			texture = FINAL_OPEN
			rotate_indic.visible = false
		else:
			texture = RETICLE_ICON
			rotate_indic.visible = false
		
		if texture == RETICLE_ICON:
			rotation_degrees = 0.0
		else:
			rotation_degrees = -35
		
