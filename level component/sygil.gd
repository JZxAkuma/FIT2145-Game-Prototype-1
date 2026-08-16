extends Area3D
enum states{
	lit,
	not_lit
}


var sygil_tween: Tween

var last_state = null

var bodies_on_plate: Array[Node3D] = []

@onready var sygil = $Sygil
@onready var animation = $Sygil/AnimationPlayer
@onready var particle = $GPUParticles3D

var state = states.not_lit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("Spinning")
	animation.pause()

	var parent = self.get_parent()
	if parent.is_in_group("door"):
		parent._register_lantern(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta: float) -> void:
	if state != last_state:
		last_state = state
		if sygil_tween:
			sygil_tween.kill()
		sygil_tween = create_tween()

		match state:
			states.lit:
				particle.emitting = true
				sygil_tween.tween_property(sygil, "position:y", 0.3, 0.5)
			states.not_lit:
				particle.emitting = false
				sygil_tween.tween_property(sygil, "position:y", 0.01, 0.5)

	if state == states.lit:
		animation.play("Spinning")
	else:
		animation.pause()


func _on_body_entered(body: Node3D) -> void:
	print("sygil detected: ", body)
	if body in bodies_on_plate:
		return
	bodies_on_plate.append(body)

	if state == states.not_lit:
		state = states.lit
		var parent = get_parent()
		if parent.is_in_group("sygil activated") or parent.is_in_group("door"):
			parent._check_lanterns()

func _on_body_exited(body: Node3D) -> void:
	bodies_on_plate.erase(body)

	if bodies_on_plate.is_empty() and state == states.lit:
		state = states.not_lit
		var parent = get_parent()
		if parent.is_in_group("sygil activated") or parent.is_in_group("door"):
			parent._check_lanterns()
