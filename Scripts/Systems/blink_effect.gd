class_name BlinkEffect
extends CanvasLayer

@onready var overlay: ColorRect = $BlinkOverlay
@onready var shader_material: ShaderMaterial = overlay.material as ShaderMaterial

@export var wake_open_duration := 2.4
@export var blink_duration := 0.28
@export var pause_between_blinks := 0.45
@export var final_close_duration := 2.6

func _ready() -> void:
	layer = 100
	
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.offset_left = 0
	overlay.offset_top = 0
	overlay.offset_right = 0
	overlay.offset_bottom = 0
	
	if shader_material == null:
		push_error("BlinkOverlay n'a pas de ShaderMaterial.")
		return
	
	set_blink_amount(1.0)
	await play_wake_open()

func set_blink_amount(value: float) -> void:
	if shader_material == null:
		return
	
	shader_material.set_shader_parameter("blink_amount", clamp(value, 0.0, 1.0))

func play_wake_open() -> void:
	var tween := create_tween()
	tween.tween_method(set_blink_amount, 1.0, 0.0, wake_open_duration)
	await tween.finished

func play_sleep_blink() -> void:
	if shader_material == null:
		return
	
	var tween := create_tween()
	
	tween.tween_method(set_blink_amount, 0.0, 0.45, blink_duration)
	tween.tween_method(set_blink_amount, 0.45, 0.0, blink_duration)
	
	tween.tween_interval(pause_between_blinks)
	
	tween.tween_method(set_blink_amount, 0.0, 0.65, blink_duration)
	tween.tween_method(set_blink_amount, 0.65, 0.0, blink_duration)
	
	tween.tween_interval(0.45)
	tween.tween_method(set_blink_amount, 0.0, 1.0, final_close_duration)
	
	await tween.finished

func hold_closed(duration: float) -> void:
	set_blink_amount(1.0)
	await get_tree().create_timer(duration).timeout
