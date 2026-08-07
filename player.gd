extends CharacterBody3D


@export var default_sens = 0.5
@export var aim_sens = 0.3
var sens = 0.5

const SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@onready var pivot: Node3D = $"camera point"
@onready var castline: RayCast3D = $"camera point/SpringArm3D/Camera3D/RayCast3D"
@onready var debug_label: Label = $"Control/casting to"
@onready var cast_point: Marker3D = $"cast point"
@export var aim_camera_pos: Vector3 = Vector3(0.969, 0.792, 0.0)
@export var aim_spring_length: float = 2.0
@export var default_spring_length: float = 5.0
@onready var crosshair: TextureRect = $Control/Crosshair
@onready var camera: Camera3D = $"camera point/SpringArm3D/Camera3D"
@onready var camerapoint: Node3D = $"camera point"
@onready var springarm: SpringArm3D = $"camera point/SpringArm3D"
@export var aim_tween_legnht: float = 0.1
var aim_tween: Tween


var waterball_scene = preload("res://water_ball.tscn")
var fireball_scene = preload("res://fireball.tscn")
var earthwall_scene = preload("res://earth_wall.tscn")
@onready var wall_indicator = preload("res://earth_wall_indicator.tscn").instantiate()

enum elements {
	water,
	earth,
	fire
}

enum states {
	default,
	aiming
}

var state: states = states.default

var selection: elements = elements.water


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
	_sens_changer()
	_update_wall_indicator()
	_camera_state()
	_cast_lenght()

	state = states.aiming if Input.is_action_pressed("aim") else states.default

	if state == states.aiming:
		if Input.is_action_just_pressed("shoot") and castline.is_colliding():
			_cast_selection()

	_change_power()
	_selection_display()
	_cast_detection()

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	move_and_slide()


func _cast_detection():
	debug_label.text = "Fps: " + str(Engine.get_frames_per_second())


func _selection_display():
	$Label3D.text = str(elements.keys()[selection])


func _change_power():
	if Input.is_action_just_pressed("scroll_up"):
		selection = (selection + 1) % elements.size()
	if Input.is_action_just_pressed("scroll_down"):
		selection = (selection - 1 + elements.size()) % elements.size()


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
				get_tree().current_scene.add_child(earthwall)
				earthwall.global_position = castline.get_collision_point()
				_align_to_surface(earthwall, castline.get_collision_point(), castline.get_collision_normal(),true)

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
			_align_to_surface(wall_indicator, castline.get_collision_point(), castline.get_collision_normal(),false)
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
