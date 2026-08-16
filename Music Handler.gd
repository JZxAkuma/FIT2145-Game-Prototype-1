extends Node
@onready var audio_stream_player = $AudioStreamPlayer
@onready var level_music = "res://Music/Game_Prototype_1_game.wav"

@export var fade_time: float = 1.0
@export var target_volume_db: float = 0.0  # normal playback volume

var current_music_path: String = ""
var fade_tween: Tween

var bgm_bus_index: int = AudioServer.get_bus_index("BGM")
var is_muted: bool = false


func _ready() -> void:
	audio_stream_player.bus = "BGM"
	audio_stream_player.volume_db = target_volume_db


func _play_music(path: String) -> void:
	current_music_path = path
	audio_stream_player.stream = load(path)
	audio_stream_player.volume_db = target_volume_db
	audio_stream_player.play()


func change_music(path: String) -> void:
	if path == current_music_path and audio_stream_player.playing:
		return

	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(audio_stream_player, "volume_db", -40.0, fade_time)
	await fade_tween.finished

	_play_music(path)
	audio_stream_player.volume_db = -40.0

	fade_tween = create_tween()
	fade_tween.tween_property(audio_stream_player, "volume_db", target_volume_db, fade_time)


func toggle_mute() -> void:
	is_muted = not is_muted
	AudioServer.set_bus_mute(bgm_bus_index, is_muted)


func set_mute(muted: bool) -> void:
	is_muted = muted
	AudioServer.set_bus_mute(bgm_bus_index, is_muted)
