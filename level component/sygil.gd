extends Area3D
enum states{
	lit,
	not_lit
}

var state = states.not_lit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = self.get_parent()
	if parent.is_in_group("sygil activated"):
		state = states.not_lit
		parent._register_sygil(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		states.lit:
			pass
		states.not_lit:
			pass


func _on_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
