extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 200

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		Transition._transition_scene("res://title_screen.tscn")
