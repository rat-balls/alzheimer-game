extends RigidBody3D

@onready var pour_point: Marker3D = $PourPoint
@onready var water_particles: GPUParticles3D = $PourPoint/WaterParticules
var filled : bool = false
@export var pour_threshold : float = 0.4

func _ready() -> void:
	water_particles.emitting = false

func fill() -> void:
	if filled:
		return

	filled = true
	print("filled")

func _physics_process(_delta: float) -> void:
	if !filled:
		water_particles.emitting = false
		return
	var opening_direction : Vector3 = pour_point.global_transform.basis.y
	var is_opening_down : float = opening_direction.dot(Vector3.DOWN)
	water_particles.emitting = is_opening_down > pour_threshold
