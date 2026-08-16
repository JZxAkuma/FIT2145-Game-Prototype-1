extends Node3D

@export_multiline var dialogue_text: String = "Hello there!"
@export var dialogue_duration: float = 4.0

@onready var talk_indicator: Label3D = $TalkIndicator
@onready var dialogue_bubble: Label3D = $DialogueBubble

var player_nearby: bool = false
var dialogue_open: bool = false
var dialogue_timer: float = 0.0


func _ready() -> void:
	talk_indicator.visible = false
	dialogue_bubble.visible = false


func _process(delta: float) -> void:
	if dialogue_open:
		dialogue_timer -= delta

		if dialogue_timer <= 0.0:
			close_dialogue()


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		interact()


func set_player_nearby(nearby: bool) -> void:
	player_nearby = nearby

	if not dialogue_open:
		talk_indicator.visible = nearby


func interact() -> void:
	if dialogue_open:
		close_dialogue()
	else:
		open_dialogue()


func open_dialogue() -> void:
	dialogue_open = true
	talk_indicator.visible = false

	dialogue_bubble.text = dialogue_text
	dialogue_bubble.visible = true

	dialogue_timer = dialogue_duration


func close_dialogue() -> void:
	dialogue_open = false
	dialogue_bubble.visible = false

	if player_nearby:
		talk_indicator.visible = true


func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		set_player_nearby(true)


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		set_player_nearby(false)
