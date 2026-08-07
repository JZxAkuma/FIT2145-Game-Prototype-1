extends CanvasLayer

@onready var logo = $Control/logo
@onready var anim_player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("fade_in")

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("shoot"):
		#get_tree().change_scene_to_file("res://world.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		get_tree().change_scene_to_file("res://world.tscn")

func _fade_in_done():
	anim_player.play("fade out")

func _fade_out_done():
	get_tree().change_scene_to_file("res://world.tscn")
