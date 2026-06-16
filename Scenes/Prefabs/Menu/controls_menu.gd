extends Control

signal back_pressed

@onready var back_button = $BackButton

func _ready() -> void:
	hide()
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	hide()
	back_pressed.emit()
