extends StaticBody3D
@onready var water = $Node3D
@export var max_water: int = 5
@export var current_water = 0
@onready var radius_part = $"radius particle"
@onready var vertical_part = $"vertical particles"
@onready var steam_detector = $"Steam detector origin/steam detector"
@onready var steam_detector_origin = $"Steam detector origin"

@export var max_water_scale: float = 11.0
@export var steam_duration: float = 1.5
@export var max_upward_force: float = 12.0
@export var max_detector_height: float = 3.0

var steam_active: bool = false
var steam_ratio: float = 0.0
var steam_timer: float = 0.0

var radius_base_velocity_min: float
var radius_base_velocity_max: float
var vertical_base_velocity_min: float
var vertical_base_velocity_max: float

var radius_base_scale_min: float
var radius_base_scale_max: float
var vertical_base_scale_min: float
var vertical_base_scale_max: float

@export var unlimited_water:bool = false

func _ready() -> void:
	if unlimited_water:
		current_water = max_water

	radius_base_velocity_min = radius_part.process_material.initial_velocity_min
	radius_base_velocity_max = radius_part.process_material.initial_velocity_max
	vertical_base_velocity_min = vertical_part.process_material.initial_velocity_min
	vertical_base_velocity_max = vertical_part.process_material.initial_velocity_max

	radius_base_scale_min = radius_part.process_material.scale_min
	radius_base_scale_max = radius_part.process_material.scale_max
	vertical_base_scale_min = vertical_part.process_material.scale_min
	vertical_base_scale_max = vertical_part.process_material.scale_max

	steam_detector_origin.scale.y = 0.0


func _process(delta: float) -> void:
	water.scale.y = (float(current_water) / max_water) * max_water_scale

	if steam_active:
		steam_timer -= delta
		if steam_timer <= 0.0:
			_end_steam()


func _physics_process(delta: float) -> void:
	if not steam_active:
		return

	for body in steam_detector.get_overlapping_bodies():
		_apply_steam_force(body, delta)


func _apply_steam_force(body: Node3D, delta: float) -> void:
	var force = max_upward_force * steam_ratio

	if body is RigidBody3D:
		body.apply_central_force(Vector3.UP * force)
	elif body.is_in_group("player") and "velocity" in body:
		# kinematic character bodies don't respond to physics forces,
		# so push their vertical velocity directly instead — same
		# approach as the bounce pad.
		body.velocity.y = max(body.velocity.y, force * delta * 10.0)


func _set_wet():
	if current_water < max_water:
		current_water += 1


func _set_fire():
	if current_water == 0:
		return

	var ratio = float(current_water) / max_water
	current_water = 0
	_trigger_steam(ratio)


func _trigger_steam(ratio: float) -> void:
	steam_active = true
	steam_ratio = ratio
	steam_timer = steam_duration

	radius_part.emitting = true
	vertical_part.emitting = true

	radius_part.process_material.initial_velocity_min = radius_base_velocity_min * ratio
	radius_part.process_material.initial_velocity_max = radius_base_velocity_max * ratio
	vertical_part.process_material.initial_velocity_min = vertical_base_velocity_min * ratio
	vertical_part.process_material.initial_velocity_max = vertical_base_velocity_max * ratio

	radius_part.process_material.scale_min = radius_base_scale_min * ratio
	radius_part.process_material.scale_max = radius_base_scale_max * ratio
	vertical_part.process_material.scale_min = vertical_base_scale_min * ratio
	vertical_part.process_material.scale_max = vertical_base_scale_max * ratio

	steam_detector_origin.scale.y = max_detector_height * ratio


func _end_steam() -> void:
	steam_active = false
	radius_part.emitting = false
	vertical_part.emitting = false
	steam_detector_origin.scale.y = 0.0
