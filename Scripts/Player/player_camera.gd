extends Camera3D

const SENSITIVITY = 0.003

var interact_handler: Node
var player: CharacterBody3D

var mouse_visible: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var scene_tree = get_tree()
	interact_handler = scene_tree.get_first_node_in_group("InteractHandler")
	player = scene_tree.get_first_node_in_group("Player")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ESC"):
		handle_mouse_visible()
	
	#Prevent camera from rotating in menu
	if event is InputEventMouseMotion and !mouse_visible:
		if !interact_handler.is_rotating_object:
			rotation.x -= event.relative.y * SENSITIVITY
			#Prevent camera from rotating verticaly
			rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(80)) 
			player.rotation.y -= event.relative.x * SENSITIVITY

	

func handle_mouse_visible():
	if(!mouse_visible):
		mouse_visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		mouse_visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
