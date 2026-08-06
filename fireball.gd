extends Area3D


var target = null
var target_position:Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(target_position,Vector3.UP)
	global_position += -global_transform.basis.z * 20.0 *delta


func _on_area_entered(area: Area3D) -> void:
	self.queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body == target:
		if body.has_method("_set_fire"):
			body._set_fire()
		self.queue_free()
