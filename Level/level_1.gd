extends Node3D

@onready var player = $player
@onready var player_camera = $"player/camera point/SpringArm3D/Camera3D"

@onready var menu = $Menu
@onready var menu_control = $Menu/Control
@onready var menu_camera = $"menu camera anchor/Menu camera"

@export var camera_move_time: float = 1.5
var camera_tween: Tween

@onready var fire_image = $"menu camera anchor/Menu camera/FireImage"
@onready var fire_image2 = $"menu camera anchor/Menu camera/FireImage2"

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
	$AnimationPlayer.stop()
	on_menu = false  
	$"Menu/Control/VBoxContainer/To level".disabled = true
	$"Menu/Control/VBoxContainer/to world".disabled = true

	var target_pos = player_camera.global_position
	var target_basis = player_camera.global_transform.basis

	if camera_tween:
		camera_tween.kill()
	camera_tween = create_tween()
	camera_tween.set_parallel(true)
	camera_tween.tween_property(fire_image,"global_position:y",100,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(fire_image2,"global_position:y",100,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(menu_control,"modulate:a",0,0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(menu_camera, "global_position", target_pos, camera_move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(menu_camera, "global_transform:basis", target_basis, camera_move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	camera_tween.chain().tween_callback(_finish_camera_move)


func _finish_camera_move() -> void:
	fire_image.hide()
	fire_image2.hide()
	menu_control.hide()
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
