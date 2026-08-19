extends StaticBody3D

@onready var btimer = $"burn timer"
@onready var qftimer = $"que_free timer"

var burn_fin = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_fire():
	btimer = $"burn timer"
	$CPUParticles3D.emitting = true
	if btimer.paused != true:
		btimer.start()
	else:
		btimer.paused = false

func _set_wet():
	if burn_fin:
		return

	btimer.paused = true
	$CPUParticles3D.emitting = false

func _on_burn_timer_timeout() -> void:
	$Node3D.hide()
	$CollisionShape3D.disabled = true
	$CPUParticles3D.emitting = false
	qftimer.start()
	burn_fin = true

func _on_que_free_timer_timeout() -> void:
	self.queue_free()
