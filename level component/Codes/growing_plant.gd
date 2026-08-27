extends StaticBody3D

@onready var vine = $Vine
@onready var leaf1 = $Leaf8
@onready var leaf2 = $Leaf1
@onready var leaf3 = $Leaf9
@onready var leaf4 = $Leaf10

var wet = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StaticBody3D/CollisionShape3D.disabled = true
	vine.scale = Vector3(1.0,0.638,1.0)
	leaf1.position = Vector3(-0.488,0.834,0.7)
	leaf3.position = Vector3(-0.042,1.491,-0.47)
	leaf2.position = Vector3(-0.73,0.508,0.668)
	leaf4.position = Vector3(0.041,1.566,0.177)
	leaf4.scale = Vector3(0.13,0.011,0.13)
	leaf4.rotation = Vector3(deg_to_rad(-27.7),deg_to_rad(50.8),deg_to_rad(-29.7))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _set_wet():
	if wet:
		return

	$AnimationPlayer.play("grow")
	wet = true
	
	
