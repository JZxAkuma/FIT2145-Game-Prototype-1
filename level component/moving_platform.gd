extends Node3D
var lanterns: Array[Node3D] = []
@onready var platform = $PowerPlatform
@onready var pos_1 = $"pos 1"
@onready var pos_2 = $"pos 2"
@onready var timer = $Timer
@export var move_speed: float = 20.0
@export var arrival_threshold: float = 0.05
@export var light_power: float = 2.0
@onready var light = $PowerPlatform/OmniLight3D

enum platform_mode {
	shuttle,        
	toggle_advance, 
	follow_lit      
}
@export var mode: platform_mode = platform_mode.shuttle

enum states {
	lit,
	not_lit
}
var state = states.not_lit
var current_target: Node3D
var waiting: bool = false


func _ready() -> void:
	current_target = pos_1
	timer.one_shot = true
	timer.timeout.connect(_switch)
	pos_1.global_position = platform.global_position
	_check_lanterns()


func _process(delta: float) -> void:
	match state:
		states.not_lit:
			light.light_energy = 0
			if mode == platform_mode.follow_lit:
				_move_toward(pos_1.global_position, delta)

		states.lit:
			light.light_energy = light_power
			match mode:
				platform_mode.shuttle:
					_movement(delta)
				platform_mode.toggle_advance:
					_move_toward(current_target.global_position, delta)
				platform_mode.follow_lit:
					_move_toward(pos_2.global_position, delta)


func _movement(delta: float) -> void:
	if waiting:
		return
	var target = current_target.global_position
	var to_target = target - platform.global_position
	var distance = to_target.length()
	if distance <= arrival_threshold:
		platform.global_position = target
		waiting = true
		timer.start()
		return
	var step = move_speed * delta
	if step > distance:
		step = distance
	platform.global_position += to_target.normalized() * step


func _move_toward(target: Vector3, delta: float) -> void:
	var to_target = target - platform.global_position
	var distance = to_target.length()
	if distance <= arrival_threshold:
		platform.global_position = target
		return
	var step = move_speed * delta
	if step > distance:
		step = distance
	platform.global_position += to_target.normalized() * step 


func _switch() -> void:
	waiting = false
	current_target = pos_2 if current_target == pos_1 else pos_1


func _register_lantern(lantern: Node3D) -> void:
	lanterns.append(lantern)


func _check_lanterns() -> void:
	for lantern in lanterns:
		if lantern.state != lantern.states.lit:
			_set_inactive()
			return
	_set_active()


func _set_active() -> void:
	if state != states.lit:
		state = states.lit
		if mode == platform_mode.toggle_advance:
			current_target = pos_2 if current_target == pos_1 else pos_1


func _set_inactive() -> void:
	if state != states.not_lit:
		state = states.not_lit
