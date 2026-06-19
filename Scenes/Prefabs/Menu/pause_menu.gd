extends Control

@export var main_menu_path := "res://Scenes/Prefabs/Menu/main_menu.tscn"
@export var options_menu: Control

@onready var resume_button = $Panel/Content/ResumeButton
@onready var options_button = $Panel/Content/OptionsButton
@onready var main_menu_button = $Panel/Content/MainMenuButton
@onready var quit_button = $Panel/Content/QuitButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.pressed.connect(_resume_game)
	options_button.pressed.connect(_open_options)
	main_menu_button.pressed.connect(_go_to_main_menu)
	quit_button.pressed.connect(_quit_game)

	if options_menu:
		options_menu.hide()
		options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		options_menu.back_pressed.connect(_on_options_back_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if options_menu and options_menu.visible:
			options_menu.hide()
			show()
		elif get_tree().paused:
			_resume_game()
		else:
			_pause_game()

func _pause_game() -> void:
	show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _resume_game() -> void:
	hide()
	if options_menu:
		options_menu.hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _open_options() -> void:
	hide()
	if options_menu:
		options_menu.show()

func _on_options_back_pressed() -> void:
	if options_menu:
		options_menu.hide()
	show()

func _go_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)

func _quit_game() -> void:
	get_tree().quit()
