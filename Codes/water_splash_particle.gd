extends GPUParticles3D
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.emitting = true
	_selfdestruct()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _selfdestruct():
	timer.start()


func _on_timer_timeout() -> void:
	self.queue_free()
