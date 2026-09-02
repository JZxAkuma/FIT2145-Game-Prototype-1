extends Node3D
@export var bounce_scale = 0.8
var bounce_velocity = 11
var cap_tween : Tween
@onready var cap = $Area3D/Cap
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if cap_tween:
			cap_tween.kill()
		
		cap_tween = create_tween()
		cap.scale = Vector3(bounce_scale,bounce_scale,bounce_scale)
		cap_tween.tween_property(cap, "scale", Vector3.ONE, 0.2)
		_bounce(body)
		$AudioStreamPlayer3D.play()

func _bounce(player: Node3D):
	player.velocity.y = 0
	player.velocity.y = bounce_velocity
	
