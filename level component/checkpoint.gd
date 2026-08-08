extends StaticBody3D

@onready var respawn_point = $"respawn point"
@onready var label = $Label3D

enum states {
	active,
	not_active
}

var state = states.not_active
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(states.keys()[state])


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		RespawnManager._set_checkpoint(self,respawn_point.global_position)

func _activate():
	state = states.active

func _deactivate():
	state = states.not_active
