extends GPUParticles3D
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.emitting = true
	_selfdestruct()

func _process(delta: float) -> void:
	$OmniLight3D.light_energy -= 5 * delta
	if $OmniLight3D.light_energy <= 0:
		$OmniLight3D.light_energy = 0

func _selfdestruct():
	timer.start()

func _on_timer_timeout() -> void:
	self.queue_free()
