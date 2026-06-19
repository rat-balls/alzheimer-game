extends AudioStreamPlayer

@onready var timer: Timer = $"../HouseAmbienceTimer"

func _ready() -> void:
	autoplay = false
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	_restart_timer()

func _on_timer_timeout() -> void:
	play()
	_restart_timer()

func _restart_timer() -> void:
	timer.wait_time = randf_range(12.0, 25.0)
	timer.start()
