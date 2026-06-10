extends RigidBody3D
@onready var pour_point: Marker3D = $PourPoint
@onready var coffee_particles: GPUParticles3D = $PourPoint/CoffeeParticles
@export var pour_angle_threshold : float= 0.4

func _ready() -> void:
	coffee_particles.emitting = false

func _physics_process(_delta: float) -> void:
	var opening_direction := pour_point.global_transform.basis.y
	var is_opening_down := opening_direction.dot(Vector3.DOWN)

	coffee_particles.emitting = is_opening_down > pour_angle_threshold
