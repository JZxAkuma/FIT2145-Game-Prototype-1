extends Node

var current_checkpoint = null
var respawn_point = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _respawn():
	if current_checkpoint:
		var player = get_tree().get_first_node_in_group("player")
		player.global_position = respawn_point
	
	else:
		get_tree().reload_current_scene()

func _set_checkpoint(checkpoint : StaticBody3D, spawn_point : Vector3):
	if current_checkpoint:
		current_checkpoint._deactivate()
		current_checkpoint = null
		respawn_point = null

	respawn_point = spawn_point
	current_checkpoint = checkpoint
	current_checkpoint._activate()
