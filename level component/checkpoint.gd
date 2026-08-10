extends StaticBody3D

@onready var respawn_point = $"respawn point"
@onready var label = $Label3D
@onready var flag = $Flag
@export var tween_speed:float = 0.1
@export var hide_depth : float = -2.964
var flag_tween : Tween

enum states {
	active,
	not_active
}

var state = states.not_active
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		states.active:
			pass
		states.not_active:
			pass
	


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		RespawnManager._set_checkpoint(self,respawn_point.global_position)

func _activate():
	state = states.active
	if flag_tween:
		flag_tween.kill()
	
	flag_tween = create_tween()
	flag_tween.tween_property(flag,"position:y",0,tween_speed)

func _deactivate():
	state = states.not_active
	if flag_tween:
		flag_tween.kill()
	
	flag_tween = create_tween()
	flag_tween.tween_property(flag,"position:y",hide_depth,tween_speed)
	
