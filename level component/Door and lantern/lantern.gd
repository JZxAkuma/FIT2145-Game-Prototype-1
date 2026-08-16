extends StaticBody3D

enum states{
	lit,
	not_lit
}

var state:states = states.not_lit
@onready var particles = $CPUParticles3D
@onready var glass =  $LanternGlass
@onready var fire_detector = $CollisionShape3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = self.get_parent()
	if parent.is_in_group("door"):
		state = states.not_lit
		parent._register_lantern(self)
		fire_detector.show()
		glass.hide()
		particles.show()
	else:
		particles.hide()
		fire_detector.hide()
		glass.show()
		state = states.lit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		states.lit:
			particles.emitting = true
		states.not_lit:
			particles.emitting = false

func _set_fire():
	if state == states.not_lit:
		state = states.lit
		var parent = get_parent()
		if parent.is_in_group("door"):
			parent._check_lanterns()

func _set_wet():
	if state == states.lit:
		state = states.not_lit
		var parent = get_parent()
		if parent.is_in_group("door"):
			parent._check_lanterns()
