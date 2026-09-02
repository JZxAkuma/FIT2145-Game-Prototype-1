extends Node3D

@onready var mesh: MeshInstance3D = $Rock2
@export var valid_material: Material
@export var invalid_material: Material

func set_valid(is_valid: bool) -> void:
	mesh.material_override = valid_material if is_valid else invalid_material

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
