extends CanvasLayer

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _transition_scene(scene: String):
	#animation_player.play("fade_in")
	#await animation_player.animation_finished
#
	#get_tree().change_scene_to_file(scene)
#
	#await get_tree().process_frame
	#animation_player.play("fade_out")

func _transition_scene(scene: String):
	animation_player.play("fade_in")
	await animation_player.animation_finished

	var old_scene = get_tree().current_scene
	get_tree().change_scene_to_file(scene)

	while get_tree().current_scene == old_scene:
		await get_tree().process_frame

	animation_player.play("fade_out")
