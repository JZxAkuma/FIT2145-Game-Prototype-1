extends StaticBody3D

enum states{
	dry,
	wet
}

var state : states = states.dry
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label3D.text = str(states.keys()[state])
	if state == states.wet:
		self.scale.y -= 0.1 * delta
		if self.scale.y <= 0:
			self.queue_free()

func _set_wet():
	state = states.wet

func _set_fire():
	if state == states.wet:
		state = states.dry
