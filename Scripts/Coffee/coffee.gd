extends RigidBody3D

@onready var coffee_particles: GPUParticles3D = $PourPoint/CoffeeParticles

@export var pour_angle_threshold : float= 0.55

func _ready() -> void:
	coffee_particles.emitting = false

func _physics_process(_delta: float) -> void:
	var bag_up = global_transform.basis.y
	var world_up = Vector3.UP

	var tilt_amount = bag_up.dot(world_up)

	if tilt_amount < pour_angle_threshold:
		coffee_particles.emitting = true
	else:
		coffee_particles.emitting = false
