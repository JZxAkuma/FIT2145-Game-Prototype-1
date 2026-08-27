extends Area3D
var target = null
var target_position: Vector3
@export var speed: float = 20.0
@export var hit_radius: float = 0.5
@onready var blast_particle = preload("res://fire_blast_particle.tscn")

func _physics_process(delta: float) -> void:
	var to_target = target_position - global_position
	var distance = to_target.length()
	var step = speed * delta

	if distance <= max(step, hit_radius):
		if is_instance_valid(target) and target.has_method("_set_fire"):
			target._set_fire()
		global_position = target_position
		_splash()
		return

	look_at(target_position, Vector3.UP)
	global_position += -global_transform.basis.z * step


func _on_body_entered(body: Node3D) -> void:
	if body == target:
		if body.has_method("_set_fire"):
			body._set_fire()
		_splash()
		
func _splash():
	var part = blast_particle.instantiate()
	get_tree().current_scene.add_child(part)
	part.global_position = self.global_position
	self.queue_free()
