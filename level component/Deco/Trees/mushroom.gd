extends StaticBody3D

@onready var big_cap = $"Big Cap/BigCap"
@onready var small_cap = $"Small cap/SmallCap"
var bounce_velocity = 11
var big_cap_tween : Tween
@export var bounce_scale = 0.8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_big_cap_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if big_cap_tween:
			big_cap_tween.kill()
		
		big_cap_tween = create_tween()
		big_cap.scale = Vector3(bounce_scale,bounce_scale,bounce_scale)
		big_cap_tween.tween_property(big_cap, "scale", Vector3.ONE, 0.2)
		_bounce(body)
		$AudioStreamPlayer3D.play()


func _bounce(player: Node3D):
	player.velocity.y = 0
	player.velocity.y = bounce_velocity
	
