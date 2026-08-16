extends Node3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Menu/Control/VBoxContainer/Button.grab_focus()
	$Menu/Control/VBoxContainer/Button.pressed.connect(func(): print("BUTTON PRESSED"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_button_pressed() -> void:
	$Menu/Control/VBoxContainer/Button.disabled = true
	$Menu/Control/VBoxContainer/Button2.disabled = true
	
	Transition._transition_scene("res://Level/Level_1.tscn")

func _on_button_2_pressed() -> void:
	$Menu/Control/VBoxContainer/Button.disabled = true
	$Menu/Control/VBoxContainer/Button2.disabled = true
	
	Transition._transition_scene("res://world.tscn")


func _on_button_3_pressed() -> void:
	MusicHandler.toggle_mute()
