extends RigidBody3D

@onready var pour_point: Marker3D = $PourPoint
@onready var ground_coffee_particles: GPUParticles3D = $PourPoint/CoffeeParticles
@export var pour_angle_threshold: float = 0.4
@export var pour_distance: float = 1.5

var contains_ground_coffee := false

func _ready() -> void:
	ground_coffee_particles.emitting = false

func fill_ground_coffee() -> void:
	contains_ground_coffee = true

func _physics_process(_delta: float) -> void:
	if !contains_ground_coffee:
		ground_coffee_particles.emitting = false
		return

	var opening_direction := pour_point.global_transform.basis.y
	var is_opening_down := opening_direction.dot(Vector3.DOWN)

	var is_pouring := is_opening_down > pour_angle_threshold
	ground_coffee_particles.emitting = is_pouring
