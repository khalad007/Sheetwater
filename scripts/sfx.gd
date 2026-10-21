extends Node
## Small audio manager. Usage:
##   Sfx.play("door")              one-shot from res://audio/door.wav (or .ogg/.mp3)
##   Sfx.play_ambient("wind")      looping bed, replaces the previous one
##   Sfx.stop_ambient()
##   Sfx.toggle_mute()             also bound to the M key

const AUDIO_DIR := "res://audio/"
const VOICES := 8

var muted := false
var _voices: Array[AudioStreamPlayer] = []
var _ambient: AudioStreamPlayer
var _cache := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_voices.append(p)
	_ambient = AudioStreamPlayer.new()
	add_child(_ambient)
	# Restart the ambient bed when it ends, so it loops without import settings.
	_ambient.finished.connect(func(): if _ambient.stream: _ambient.play())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mute"):
		toggle_mute()


func _get_stream(sound: String) -> AudioStream:
	if _cache.has(sound):
		return _cache[sound]
	var stream: AudioStream = null
	for ext in ["wav", "ogg", "mp3"]:
		var path: String = AUDIO_DIR + sound + "." + ext
		if ResourceLoader.exists(path):
			stream = load(path)
			break
	if stream == null:
		push_warning("Sfx: missing sound '%s'" % sound)
	_cache[sound] = stream
	return stream


func play(sound: String, volume_db := 0.0, pitch := 1.0) -> void:
	var stream := _get_stream(sound)
	if stream == null:
		return
	for p in _voices:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.pitch_scale = pitch
			p.play()
			return
	# All voices busy: steal the first one.
	_voices[0].stream = stream
	_voices[0].volume_db = volume_db
	_voices[0].pitch_scale = pitch
	_voices[0].play()


func play_ambient(sound: String, volume_db := -6.0) -> void:
	var stream := _get_stream(sound)
	if stream == null or _ambient.stream == stream:
		return
	_ambient.stream = stream
	_ambient.volume_db = volume_db
	_ambient.play()


func stop_ambient() -> void:
	_ambient.stop()
	_ambient.stream = null


func toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
