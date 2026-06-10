extends Node

@export var player: Node3D
@export var player_spawn: Marker3D
@export var blink_effect: BlinkEffect

@export var loop_delay := 8.0
@export var blackout_duration := 1.5

func _ready() -> void:
	respawn_player()
	start_loop_timer()

func respawn_player() -> void:
	if player == null:
		push_error("Player pas assigné dans GameManager.")
		return
	
	if player_spawn == null:
		push_error("PlayerSpawn pas assigné dans GameManager.")
		return
	
	player.global_transform = player_spawn.global_transform

func start_loop_timer() -> void:
	await get_tree().create_timer(loop_delay).timeout
	await start_sleep_loop()

func start_sleep_loop() -> void:
	if blink_effect == null:
		push_error("BlinkEffect pas assigné dans GameManager.")
		return
	
	await blink_effect.play_sleep_blink()
	await blink_effect.hold_closed(blackout_duration)
	
	get_tree().reload_current_scene()
