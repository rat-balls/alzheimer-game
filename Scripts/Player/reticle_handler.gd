extends TextureRect

var interact_handler: Node

func _ready() -> void:
	interact_handler = get_tree().get_first_node_in_group("InteractHandler")

func _process(delta: float) -> void:
	if(interact_handler):
		if(interact_handler.held_object != null):
			visible = true
		else:
			visible = false
