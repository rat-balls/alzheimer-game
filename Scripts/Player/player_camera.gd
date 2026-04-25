extends Camera3D

const SENSITIVITY = 0.003
var player: CharacterBody3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player = get_parent()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ESC"):
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * SENSITIVITY
		player.rotation.y -= event.relative.x * SENSITIVITY
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
