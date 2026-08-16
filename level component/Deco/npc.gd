extends Node3D
##Making it so it is easy to give each one a dialogue
@export_multiline var dialogue_text: String = "(Moby vibes)"
@export var typewriter_speed: float = 0.04

@onready var talk_indicator: Label3D = $TalkIndicator
@onready var dialogue_display: Sprite3D = $DialogueDisplay
@onready var dialogue_text_label: Label = $DialogueViewport/DialogueBubble/Background/Text

var player_nearby: bool = false
var dialogue_open: bool = false
var typing: bool = false
var displayed_characters: int = 0
var indicator_timer: float = 0.0
var indicator_state: int = 0
var indicator_time: float = 0.0
var indicator_start_y: float

func _ready() -> void:
	# Hide everything when spawned in
	talk_indicator.visible = false
	dialogue_display.visible = false
	indicator_start_y = talk_indicator.position.y
	dialogue_text_label.visible_characters = 0

func _process(delta: float) -> void:
##Animating the dialogue prompt"..."

	if player_nearby and not dialogue_open:

		indicator_time += delta

		talk_indicator.position.y = (
			indicator_start_y +
			sin(indicator_time * 3.0) * 0.05
		)

		# Cycle between ., .., ...
		indicator_timer += delta

		if indicator_timer >= 0.35:
			indicator_timer = 0.0
			indicator_state += 1

			if indicator_state > 3:
				indicator_state = 1

			talk_indicator.text = ".".repeat(indicator_state)
#OOh player is here

func _on_interaction_area_body_entered(body: Node3D) -> void:

	if body.is_in_group("player"):
		player_nearby = true

		if not dialogue_open:
			talk_indicator.visible = true


##Player gone

func _on_interaction_area_body_exited(body: Node3D) -> void:

	if body.is_in_group("player"):
		player_nearby = false

		talk_indicator.visible = false
		dialogue_display.visible = false

		if dialogue_open:
			close_dialogue()

#"E" to interact as always
func _unhandled_input(event: InputEvent) -> void:

	if not player_nearby:
		return

	if event.is_action_pressed("interact"):
		interact()

func interact() -> void:

	# No dialogue currently open
	if not dialogue_open:
		open_dialogue()
		return

	# Dialogue is typing
	# Pressing interact finishes it instantly
	if typing:
		finish_typing()
		return

	# Dialogue has finished typing
	# Pressing interact closes it
	close_dialogue()

#What happen when dialogue is open.
func open_dialogue() -> void:

	dialogue_open = true
	typing = true

	# Hide the "..." indicator
	talk_indicator.visible = false

	# Show speech bubble
	dialogue_display.visible = true

	# Put NPC's dialogue into the text box
	dialogue_text_label.text = dialogue_text

	# Start with zero visible characters
	dialogue_text_label.visible_characters = 0

	displayed_characters = 0

	# Start typewriter effect
	type_text()

#Typewriter::::

func type_text() -> void:

	while displayed_characters < dialogue_text.length():

		# Stop if dialogue was closed
		if not dialogue_open:
			return

		# Add one character
		displayed_characters += 1

		dialogue_text_label.visible_characters = displayed_characters

		# Wait before next character
		await get_tree().create_timer(typewriter_speed).timeout

	# Finished typing
	typing = false


func finish_typing() -> void:

	typing = false

	displayed_characters = dialogue_text.length()

	#show all chars. 
	dialogue_text_label.visible_characters = -1

func close_dialogue() -> void:

	dialogue_open = false
	typing = false

	# Hide speech bubble
	dialogue_display.visible = false

	# Show "..." again if player is still nearby
	if player_nearby:
		talk_indicator.visible = true
