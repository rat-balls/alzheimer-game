extends Area3D

@export var water_particles: GPUParticles3D

var faucet_open : bool = false

func _ready() -> void:
	if water_particles:
		water_particles.emitting = false

func interact() -> void:
	faucet_open = !faucet_open

	if water_particles:
		water_particles.emitting = faucet_open
