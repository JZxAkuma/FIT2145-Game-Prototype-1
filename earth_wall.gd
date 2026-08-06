extends StaticBody3D
enum states {
	dry,
	wet,
	erecting
}

var wetness = 0
var state: states = states.erecting
@export var erect_speed: float = 0.5
@export var decay_speed : float = 0.1

const MIN_SCALE := 0.001

func _ready() -> void:
	self.scale.y = MIN_SCALE

func _process(delta: float) -> void:
	match state:
		states.wet:
			self.scale.y -= decay_speed * wetness * delta
			if self.scale.y <= MIN_SCALE:
				self.scale.y = MIN_SCALE
				self.queue_free()

		states.erecting:
			self.scale.y += erect_speed * delta
			if self.scale.y >= 1:
				self.scale.y = 1
				state = states.dry

	$Label3D.text = str(states.keys()[state])

func _set_wet():
	wetness += 1
	state = states.wet

func _set_fire():
	if state == states.wet:
		wetness = 0
		state = states.dry
