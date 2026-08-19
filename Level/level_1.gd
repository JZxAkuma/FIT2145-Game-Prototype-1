extends Node3D

@onready var player = $player
@onready var player_camera = $"player/camera point/SpringArm3D/Camera3D"

@onready var menu = $Menu
@onready var menu_camera = $"menu camera anchor/Menu camera"

var on_menu = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player._lock_player()
	player_camera.current = false
	menu_camera.current = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if on_menu:
		$"menu camera anchor".rotation.y += 0.2 * delta
		if Input.is_action_just_pressed("quit"):
			get_tree().quit()
	

func _on_to_level_pressed() -> void:
	menu.hide()
	on_menu = false
	$"Menu/Control/VBoxContainer/To level".disabled = true
	$"Menu/Control/VBoxContainer/to world".disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player._unlock_player()
	player_camera.current = true
	menu_camera.current = false

func _on_to_world_pressed() -> void:
	$"Menu/Control/VBoxContainer/To level".disabled = true
	$"Menu/Control/VBoxContainer/to world".disabled = true
	
	Transition._transition_scene("res://world.tscn")


func _on_mute_pressed() -> void:
	MusicHandler.toggle_mute()
