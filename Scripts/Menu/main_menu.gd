extends Control

@export var game_scene_path := "res://Scenes/sc_game.tscn"

@onready var main_buttons: VBoxContainer = $MainButtons

@onready var start_button = $MainButtons/StartButton
@onready var options_button = $MainButtons/OptionsButton
@onready var controls_button = $MainButtons/CommandesButton
@onready var credits_button = $MainButtons/CreditsButton
@onready var quit_button = $MainButtons/QuitButton

@onready var options_menu = $OptionsMenu
@onready var controls_menu = $ControlsMenu

func _ready() -> void:
	options_menu.hide()
	controls_menu.hide()

	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	options_menu.back_pressed.connect(_on_options_back_pressed)
	controls_menu.back_pressed.connect(_on_controls_back_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)

func _on_options_pressed() -> void:
	main_buttons.hide()
	options_menu.show()

func _on_options_back_pressed() -> void:
	options_menu.hide()
	main_buttons.show()

func _on_controls_pressed() -> void:
	main_buttons.hide()
	controls_menu.show()

func _on_controls_back_pressed() -> void:
	controls_menu.hide()
	main_buttons.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
