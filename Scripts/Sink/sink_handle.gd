extends Area3D

@export var water_particles: GPUParticles3D
@export var water_distance : float= 2.0

var faucet_open : bool = false

func _ready() -> void:
	if water_particles:
		water_particles.emitting = false

func interact() -> void:
	faucet_open = !faucet_open

	if water_particles:
		water_particles.emitting = faucet_open

func _physics_process(_delta: float) -> void:
	if !faucet_open or water_particles == null:
		return
	var space_state = get_world_3d().direct_space_state
	var from = water_particles.global_position
	var to = from + Vector3.DOWN * water_distance
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return

	var collider = result["collider"]

	if collider.has_method("fill"):
		collider.fill()
