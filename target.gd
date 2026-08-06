extends StaticBody3D
enum states{
	dry,
	wet,
	burn
}

@export var max_water: int = 4
var wetness = 0
var state: states = states.dry
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label3D.text = str(states.keys()[state]) + "\n" + "water level: " + str(wetness)

func _set_wet():
	if wetness < max_water:
		wetness += 1
	state = states.wet

func _set_fire():
	if state == states.dry:
		state = states.burn
	elif state == states.wet:
		wetness = 0
		state = states.dry
