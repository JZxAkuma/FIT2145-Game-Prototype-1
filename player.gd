extends CharacterBody3D

const SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var jump_cut_multiplier: float = 0.5

@export var default_sens = 0.5
@export var aim_sens = 0.3
@export var controller_sens: float = 3.0
@export var controller_aim_sens: float = 3.0
@export var controller_deadzone: float = 0.15
var sens = 0.5

@onready var pivot: Node3D = $"camera point"
@onready var castline: RayCast3D = $"camera point/SpringArm3D/Camera3D/RayCast3D"
@onready var debug_label: Label = $"CanvasLayer/Crosshair/casting to"
@onready var cast_point: Marker3D = $"cast point"
@onready var crosshair: TextureRect = $CanvasLayer/Crosshair/Crosshair
@onready var camera: Camera3D = $"camera point/SpringArm3D/Camera3D"
@onready var camerapoint: Node3D = $"camera point"
@onready var springarm: SpringArm3D = $"camera point/SpringArm3D"
@onready var player_mesh = $Player_mesh
@onready var wall_indicator = preload("res://earth_wall_indicator.tscn").instantiate()

@onready var anim_tree: AnimationTree = $AnimationTree

@export var aim_camera_pos: Vector3 = Vector3(0.969, 0.792, 0.0)
@export var aim_spring_length: float = 2.0
@export var default_spring_length: float = 5.0
@export var aim_tween_legnht: float = 0.1
var aim_tween: Tween

@export var mesh_turn_speed: float = 10.0
var last_world_facing_angle: float = 0.0

@onready var element_ui = $"CanvasLayer/Elements UI"
@onready var water_icon: TextureButton = $"CanvasLayer/Elements UI/HBoxContainer/water"
@onready var fire_icon: TextureButton = $"CanvasLayer/Elements UI/HBoxContainer/fire"
@onready var earth_icon: TextureButton = $"CanvasLayer/Elements UI/HBoxContainer/earth"
@onready var water_normal_tex = water_icon.texture_normal
@onready var fire_normal_tex = fire_icon.texture_normal
@onready var earth_normal_tex = earth_icon.texture_normal
var element_ui_tween: Tween

@export var element_change_time_scale: float = 0.2

var waterball_scene = preload("res://water_ball.tscn")
var fireball_scene = preload("res://fireball.tscn")
var earthwall_scene = preload("res://earth_wall.tscn")

@export var element_ui_offset: Vector3 = Vector3(0, 1.5, 0)

enum elements {
	water,
	earth,
	fire
}

enum states {
	default,
	aiming,
	died
}

enum changing_elements {
	changing,
	not_changing
}

var state: states = states.default
var selection: elements = elements.water
var player_lock = false

# ANIMATION-TREE-READY STATE

var is_moving: bool = false
var move_speed_ratio: float = 0.0     
var is_grounded: bool = true
var is_aiming: bool = false

signal state_changed(new_state: states)
signal selection_changed(new_selection: elements)

func _ready() -> void:
	wall_indicator.visible = false
	call_deferred("_add_wall_indicator")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _add_wall_indicator():
	get_tree().current_scene.add_child(wall_indicator)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))


func _sens_changer():
	match state:
		states.aiming:
			sens = aim_sens
		states.default:
			sens = default_sens


func _physics_process(delta: float) -> void:
	if player_lock:
		return

	_controller_look(delta)
	_sens_changer()
	_update_wall_indicator()
	_camera_state()
	_cast_lenght()
	_elements_ui()
	_update_elements_ui_position()

	_set_state(states.aiming if Input.is_action_pressed("aim") else states.default)

	if state == states.aiming:
		if Input.is_action_just_pressed("shoot") and castline.is_colliding():
			_cast_selection()

	_change_power()
	_selection_display()
	_cast_detection()

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_released("jump") and velocity.y > 0:
		velocity.y *= jump_cut_multiplier

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	_update_mesh_rotation(delta, direction)

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	move_and_slide()

	_update_animation_state()


func _cast_detection():
	debug_label.text = "Fps: " + str(Engine.get_frames_per_second())


func _selection_display():
	$Label3D.text = str(elements.keys()[selection])


func _change_power():
	if Input.is_action_pressed("change element"):
		Engine.time_scale = element_change_time_scale
		if element_ui_tween:
			element_ui_tween.kill()
		element_ui_tween = create_tween()
		element_ui_tween.tween_property(element_ui, "modulate:a", 1, aim_tween_legnht)

		if Input.is_action_just_pressed("scroll_up"):
			_set_selection((selection + 1) % elements.size())
		if Input.is_action_just_pressed("scroll_down"):
			_set_selection((selection - 1 + elements.size()) % elements.size())

	else:
		Engine.time_scale = 1
		if element_ui_tween:
			element_ui_tween.kill()
		element_ui_tween = create_tween()
		element_ui_tween.tween_property(element_ui, "modulate:a", 0, aim_tween_legnht)


func _cast_selection():
	match selection:
		elements.water:
			_spawn_projectile(waterball_scene)

		elements.fire:
			_spawn_projectile(fireball_scene)

		elements.earth:
			var target = castline.get_collider()
			if target and target.is_in_group("floor"):
				var earthwall = earthwall_scene.instantiate()
				earthwall.player_made = true
				get_tree().current_scene.add_child(earthwall)
				earthwall.global_position = castline.get_collision_point()
				_align_to_surface(earthwall, castline.get_collision_point(), castline.get_collision_normal(), true)


func _spawn_projectile(scene: PackedScene):
	var projectile = scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = cast_point.global_position

	if castline.is_colliding():
		projectile.target = castline.get_collider()
		projectile.target_position = castline.get_collision_point()
	else:
		projectile.target_position = castline.global_position + (-castline.global_transform.basis.z * 100)


func _cast_lenght():
	match selection:
		elements.water:
			castline.target_position = Vector3(0, -1000, 0)

		elements.fire:
			castline.target_position = Vector3(0, -1000, 0)

		elements.earth:
			castline.target_position = Vector3(0, -10, 0)


func _camera_state():
	if aim_tween:
		aim_tween.kill()

	aim_tween = create_tween()
	aim_tween.set_parallel(true)

	match state:
		states.aiming:
			aim_tween.tween_property(crosshair, "modulate:a", 1, aim_tween_legnht)
			aim_tween.tween_property(camerapoint, "position", aim_camera_pos, aim_tween_legnht)
			aim_tween.tween_property(springarm, "spring_length", aim_spring_length, aim_tween_legnht)

		states.default:
			aim_tween.tween_property(crosshair, "modulate:a", 0, aim_tween_legnht)
			aim_tween.tween_property(camerapoint, "position", Vector3.ZERO, aim_tween_legnht)
			aim_tween.tween_property(springarm, "spring_length", default_spring_length, aim_tween_legnht)


func _update_wall_indicator():
	if not wall_indicator.is_inside_tree():
		return

	var show_indicator = false

	if state == states.aiming and selection == elements.earth and castline.is_colliding():
		var target = castline.get_collider()
		if target and target.is_in_group("floor"):
			wall_indicator.global_position = castline.get_collision_point()
			wall_indicator.global_rotation = global_rotation
			_align_to_surface(wall_indicator, castline.get_collision_point(), castline.get_collision_normal(), false)
			show_indicator = true

	wall_indicator.visible = show_indicator


func _align_to_surface(node: Node3D, position: Vector3, normal: Vector3, flip: bool = false) -> void:
	node.global_position = position

	var up: Vector3 = normal.normalized()

	var forward: Vector3 = -global_transform.basis.z
	forward = (forward - up * forward.dot(up))
	if forward.length() < 0.001:
		forward = global_transform.basis.x
		forward = (forward - up * forward.dot(up))
	forward = forward.normalized()

	var right: Vector3 = forward.cross(up).normalized()
	forward = up.cross(right).normalized()

	node.global_transform.basis = Basis(right, up, forward)

	if flip:
		node.rotate_object_local(Vector3.RIGHT, PI)


func _controller_look(delta: float) -> void:
	var look_sens: float
	match state:
		states.default:
			look_sens = controller_sens
		states.aiming:
			look_sens = controller_aim_sens
		_:
			look_sens = controller_sens

	var look_vec := Input.get_vector("look left", "look right", "look up", "look down")
	if look_vec.length() < controller_deadzone:
		return

	rotate_y(-look_vec.x * look_sens * delta)
	pivot.rotate_x(-look_vec.y * look_sens * delta)
	pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))


func _lock_player():
	if player_lock == false:
		player_lock = true


func _unlock_player():
	if player_lock == true:
		player_lock = false


func _on_hurt_box_area_entered(area: Area3D) -> void:
	RespawnManager._respawn()


func _to_checkpoint_spot(spawnpoint: Vector3) -> void:
	pass


func _elements_ui():
	water_icon.texture_normal = water_icon.texture_hover if selection == elements.water else water_normal_tex
	fire_icon.texture_normal = fire_icon.texture_hover if selection == elements.fire else fire_normal_tex
	earth_icon.texture_normal = earth_icon.texture_hover if selection == elements.earth else earth_normal_tex


func _update_mesh_rotation(delta: float, direction: Vector3) -> void:
	var target_rotation_y: float

	if state == states.aiming:
		target_rotation_y = 0.0
	else:
		if direction.length() > 0.1:
			last_world_facing_angle = atan2(-direction.x, -direction.z)
		target_rotation_y = last_world_facing_angle - rotation.y

	player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, target_rotation_y, mesh_turn_speed * delta)

func _set_state(new_state: states) -> void:
	if state == new_state:
		return
	state = new_state
	is_aiming = state == states.aiming
	state_changed.emit(state)

func _set_selection(new_selection) -> void:
	if selection == new_selection:
		return
	selection = new_selection
	selection_changed.emit(selection)


func _update_animation_state() -> void:
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	move_speed_ratio = clamp(horizontal_speed / SPEED, 0.0, 1.0)
	is_moving = horizontal_speed > 0.1
	is_grounded = is_on_floor()

	if anim_tree:
		pass
		# anim_tree.set("parameters/Move/blend_position", move_speed_ratio)
		# anim_tree.set("parameters/conditions/is_grounded", is_grounded)
		# anim_tree.set("parameters/conditions/is_aiming", is_aiming)
		# anim_tree.set("parameters/Selection/blend_position", selection)

func _update_elements_ui_position() -> void:
	var world_pos = global_position + element_ui_offset

	if camera.is_position_behind(world_pos):
		element_ui.visible = false
		return

	element_ui.visible = true
	var screen_pos = camera.unproject_position(world_pos)
	element_ui.position = screen_pos - (element_ui.size / 2.0)
