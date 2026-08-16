extends Area3D
var target = null
var target_position: Vector3
@export var speed: float = 20.0
@export var hit_radius: float = 0.5
@export var push_velocity: float = 5

func _physics_process(delta: float) -> void:
	var to_target = target_position - global_position
	var distance = to_target.length()
	var step = speed * delta
	if distance <= max(step, hit_radius):
		if is_instance_valid(target) and target.has_method("_set_wet"):
			target._set_wet()
		global_position = target_position
		queue_free()
		return
	look_at(target_position, Vector3.UP)
	global_position += -global_transform.basis.z * step

func _on_area_entered(area: Area3D) -> void:
	self.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		var push_dir = -global_transform.basis.z
		body.apply_central_impulse(push_dir * push_velocity * body.mass)

	if body == target:
		if body.has_method("_set_wet"):
			body._set_wet()
		queue_free()
