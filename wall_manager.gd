extends Node

@export var max_walls: int = 5
var walls: Array[Node] = []

func register_wall(wall: Node) -> void:
	walls.append(wall)
	wall.tree_exiting.connect(_on_wall_freed.bind(wall))

	if walls.size() > max_walls:
		var oldest = walls[0]
		if is_instance_valid(oldest):
			oldest._expire()

func _on_wall_freed(wall: Node) -> void:
	walls.erase(wall)
