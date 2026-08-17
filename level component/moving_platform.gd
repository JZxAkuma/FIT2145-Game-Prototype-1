extends Node3D
var lanterns: Array[Node3D] = []
@onready var platform = $PowerPlatform
@onready var pos_1 = $"pos 1"
@onready var pos_2 = $"pos 2"


enum states{
	lit,
	not_lit
}

var state = states.not_lit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _register_lantern(lantern: Node3D) -> void:
	lanterns.append(lantern)
	
func _check_lanterns() -> void:
	for lantern in lanterns:
		if lantern.state != lantern.states.lit:
			_set_active()
			return
	_set_active()

func _set_active() -> void:
	if state != states.lit:
		state = states.lit
	
func _set_inactive() -> void:
	if state != states.not_lit:
		state = states.not_lit
