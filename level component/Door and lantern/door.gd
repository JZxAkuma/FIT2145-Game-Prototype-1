extends StaticBody3D
var lanterns: Array[Node3D] = []
@onready var door = $EndDoor1
var door_tween: Tween
@export var tween_speed: float = 1.0
@export var open_rotation_degrees: float = 46.4
@onready var scene_changer = $"Scene changer"
@export var change_scene_to: String
@onready var particle = $GPUParticles3D
@onready var light = $OmniLight3D

enum states {
	open,
	close
}

var state: states = states.close
var closed_rotation_y: float
var count = 0

func _ready() -> void:
	closed_rotation_y = door.rotation.y
	_check_lanterns()

func _process(delta: float) -> void:
	match state:
		states.open:
			#light.light_energy = 1
			particle.emitting = true
			scene_changer.monitoring = true
		states.close:
			#light.light_energy = 0
			particle.emitting = false
			scene_changer.monitoring = false

func _open_door():
	if state == states.close:
		state = states.open
		if door_tween:
			door_tween.kill()
		door_tween = create_tween()
		door_tween.set_parallel(true)
		door_tween.tween_property(door, "rotation:y", closed_rotation_y - deg_to_rad(open_rotation_degrees), tween_speed)
		door_tween.tween_property(light,"light_energy",1,tween_speed)

func _close_door():
	if state == states.open:
		state = states.close
		if door_tween:
			door_tween.kill()
		door_tween = create_tween()
		door_tween.set_parallel(true)
		door_tween.tween_property(door, "rotation:y", closed_rotation_y, tween_speed)
		door_tween.tween_property(light,"light_energy",1,tween_speed)

func _register_lantern(lantern: Node3D) -> void:
	lanterns.append(lantern)
	
func _check_lanterns() -> void:
	for lantern in lanterns:
		if lantern.state != lantern.states.lit:
			_close_door()
			return
	_open_door()

func _on_scene_changer_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		RespawnManager.current_checkpoint = null
		RespawnManager.respawn_point = null
		body._lock_player()
		
		if change_scene_to:
			#get_tree().change_scene_to_file(change_scene_to)
			#print(change_scene_to)
			Transition._transition_scene(change_scene_to)
		else:
			get_tree().reload_current_scene()
