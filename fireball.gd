extends Area3D
var target = null
var target_position: Vector3
@export var speed: float = 20.0
@export var hit_radius: float = 0.5

func _physics_process(delta: float) -> void:
	var to_target = target_position - global_position
	var distance = to_target.length()
	var step = speed * delta

	if distance <= max(step, hit_radius):
		if is_instance_valid(target) and target.has_method("_set_fire"):
			target._set_fire()
		global_position = target_position
		queue_free()
		return

	look_at(target_position, Vector3.UP)
	global_position += -global_transform.basis.z * step

func _on_area_entered(area: Area3D) -> void:
	self.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body == target:
		if body.has_method("_set_fire"):
			body._set_fire()
		queue_free()
