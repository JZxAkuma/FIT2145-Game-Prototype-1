extends CharacterBody3D


@export var sens = 0.5
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var pivot: Node3D = $"camera point"
@onready var castline: RayCast3D = $"camera point/SpringArm3D/Camera3D/RayCast3D"
@onready var debug_label: Label = $"Control/casting to"
@onready var cast_point: Marker3D = $"cast point"

var waterball_scene = preload("res://water_ball.tscn")
var fireball_scene = preload("res://fireball.tscn")
var earthwall_scene = preload("res://earth_wall.tscn")

enum elements {
	water,
	earth,
	fire
}

var selection: elements = elements.water

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90),deg_to_rad(45))
	
func _physics_process(delta: float) -> void:
	_cast_lenght()
	if Input.is_action_just_pressed("shoot"):
		if castline.is_colliding():
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
			var waterball = waterball_scene.instantiate()
			get_tree().current_scene.add_child(waterball)
			waterball.global_position = cast_point.global_position
			
			if castline.is_colliding():
				var collider = castline.get_collider()
				waterball.target_position = castline.get_collision_point()
			
			else:
				waterball.target_position = castline.global_position+ (-castline.global_transform.basis.z * 100)
		
		elements.fire:
			var fireball = fireball_scene.instantiate()
			get_tree().current_scene.add_child(fireball)
			fireball.global_position = cast_point.global_position
			
			if castline.is_colliding():
				var collider = castline.get_collider()
				fireball.target_position = castline.get_collision_point()
			
			else:
				fireball.target_position = castline.global_position+ (-castline.global_transform.basis.z * 100)
		
		elements.earth:
			var target = castline.get_collider()
			if target.is_in_group("floor"):
				var earthwall = earthwall_scene.instantiate()
				get_tree().current_scene.add_child(earthwall)
				earthwall.global_position = castline.get_collision_point()
				earthwall.global_rotation = global_rotation

func _cast_lenght():
	match selection:
		elements.water:
			castline.target_position = Vector3(0,-1000,0)
		
		elements.fire:
			castline.target_position = Vector3(0,-1000,0)
		
		elements.earth:
			castline.target_position = Vector3(0,-300,0)
			
			
			
			
			
			
