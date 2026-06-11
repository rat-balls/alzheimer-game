extends RigidBody3D
@onready var pour_point: Marker3D = $PourPoint
@onready var coffee_particles: GPUParticles3D = $PourPoint/CoffeeParticles
@export var pour_angle_threshold : float= 0.4
@export var pour_distance: float = 1.5
func _ready() -> void:
	coffee_particles.emitting = false

func _physics_process(_delta: float) -> void:
	var opening_direction := pour_point.global_transform.basis.y
	var is_opening_down := opening_direction.dot(Vector3.DOWN)
	var is_pouring := is_opening_down > pour_angle_threshold
	coffee_particles.emitting = is_pouring
	if !is_pouring:
		return
	var space_state = get_world_3d().direct_space_state
	var from = pour_point.global_position
	var to = from + Vector3.DOWN * pour_distance

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return

	var collider = result["collider"]

	if collider.has_method("fill"):
		collider.fill()
	
