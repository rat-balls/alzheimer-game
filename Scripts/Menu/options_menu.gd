extends Control

signal back_pressed

@onready var fullscreen_checkbox: CheckBox = $Panel/Content/FullscreenCheckBox
@onready var volume_slider: HSlider = $Panel/Content/VolumeSlider
@onready var sensitivity_slider: HSlider = $Panel/Content/SensitivitySlider
@onready var back_button = $Panel/Content/BackButton

func _ready() -> void:
	hide()

	fullscreen_checkbox.button_pressed = false

	volume_slider.min_value = 0.0
	volume_slider.max_value = 100.0
	volume_slider.step = 1.0
	volume_slider.value = 80.0

	sensitivity_slider.min_value = 1.0
	sensitivity_slider.max_value = 10.0
	sensitivity_slider.step = 0.1
	sensitivity_slider.value = 5.0

	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	back_button.pressed.connect(_on_back_pressed)

func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volume_changed(value: float) -> void:
	var volume: float = value / 100.0
	
	if volume <= 0.0:
		volume = 0.001
	
	var bus_index: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

func _on_sensitivity_changed(value: float) -> void:
	print("Sensibilité souris :", value)

func _on_back_pressed() -> void:
	hide()
	back_pressed.emit()
