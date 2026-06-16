extends Control

signal pressed

@export var button_text := "BUTTON"

@onready var texture_button: TextureButton = $TextureButton
@onready var label: Label = $Label
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound

func _ready() -> void:
	label.text = button_text
	
	texture_button.mouse_entered.connect(_on_mouse_entered)
	texture_button.pressed.connect(_on_pressed)

func _on_mouse_entered() -> void:
	hover_sound.play()

func _on_pressed() -> void:
	click_sound.play()
	pressed.emit()
