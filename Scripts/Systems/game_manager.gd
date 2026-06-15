extends Node

@export var player: Node3D
@export var player_spawn: Marker3D
@export var blink_effect: BlinkEffect
@export var alarm_sound: AudioStreamPlayer3D

@export var loop_delay := 20.0
@export var silence_before_fall := 0.4
@export var blackout_after_fall := 1.5

@export var yawn_sound_path := NodePath("YawnSound")
@export var fall_sound_path := NodePath("FallSound")

var yawn_sound: AudioStreamPlayer3D
var fall_sound: AudioStreamPlayer3D

func _ready() -> void:
	respawn_player()
	setup_player_sounds()
	play_sound(alarm_sound)
	start_loop_timer()

func setup_player_sounds() -> void:
	if player == null:
		return
	
	yawn_sound = player.get_node_or_null(yawn_sound_path)
	fall_sound = player.get_node_or_null(fall_sound_path)

	if yawn_sound == null:
		push_error("YawnSound introuvable dans Player.")
	
	if fall_sound == null:
		push_error("FallSound introuvable dans Player.")

func respawn_player() -> void:
	if player == null:
		push_error("Player pas assigné dans GameManager.")
		return
	
	if player_spawn == null:
		push_error("PlayerSpawn pas assigné dans GameManager.")
		return
	
	player.global_transform = player_spawn.global_transform
	DiseaseProgManager.increment_prog(100)

func start_loop_timer() -> void:
	await get_tree().create_timer(loop_delay).timeout
	await start_sleep_loop()

func start_sleep_loop() -> void:
	play_sound(yawn_sound)
	
	if yawn_sound != null:
		await yawn_sound.finished
	
	if blink_effect == null:
		push_error("BlinkEffect pas assigné dans GameManager.")
		return
	
	await blink_effect.play_sleep_blink()
	await blink_effect.hold_closed(silence_before_fall)
	
	play_sound(fall_sound)
	
	if fall_sound != null:
		await fall_sound.finished
	
	await blink_effect.hold_closed(blackout_after_fall)
	get_tree().reload_current_scene()

func play_sound(sound: AudioStreamPlayer3D) -> void:
	if sound != null:
		sound.play()
