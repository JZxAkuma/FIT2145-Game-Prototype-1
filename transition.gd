extends CanvasLayer

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _transition_scene(scene: PackedScene):
	animation_player.play("fade_in")
	await animation_player.animation_finished
	await get_tree().change_scene_to_packed(scene)
	animation_player.play("fade_out")
