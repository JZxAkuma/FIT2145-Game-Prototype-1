extends Area3D

var target = null
var target_position:Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if target:
		#look_at(target.global_position,Vector3.UP)
		#global_position += -global_transform.basis.z * 20 * delta
	#else:
		#look_at(target_position,Vector3.UP)
		#global_position += -global_transform.basis.z * 20.0 *delta
	
	look_at(target_position,Vector3.UP)
	global_position += -global_transform.basis.z * 20.0 *delta




func _on_area_entered(area: Area3D) -> void:
	self.queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body == target:
		if body.has_method("_set_wet"):
			body._set_wet()
		self.queue_free()
