extends Control
## Host: owns exactly one room at a time and swaps it with a fade.
## Room ids pass through RoomData.resolve(), so variants apply to every entry point.
## Debug builds: F7 gives every item, sets the story flags and jumps to the chapel.

const ROOM_SCENE: PackedScene = preload("res://scenes/room.tscn")
const START_ROOM: String = "bus_stop"
const FADE_TIME: float = 0.45

var _current: RoomView
var _busy: bool = false


func _ready() -> void:
	Fade.set_black()
	_load_room(START_ROOM)
	await Fade.from_black(FADE_TIME)
	_current.on_shown()


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or not OS.is_debug_build():
		return
	if key.keycode == KEY_F7:
		_debug_jump_to_chapel()
	elif key.keycode == KEY_F8:
		_debug_new_loop(false)
	elif key.keycode == KEY_F9:
		_debug_new_loop(true)


## Debug only. F8: start a fresh loop. F9: same, but "She Looked Away" counts as already seen.
func _debug_new_loop(with_away: bool) -> void:
	if Dialogue.active or Ending.active or _busy:
		return
	if with_away:
		GameState.record_ending("away")
	GameState.new_loop()
	Notebook.reset()
	get_tree().reload_current_scene()


func _debug_jump_to_chapel() -> void:
	if Dialogue.active or Ending.active or _busy:
		return
	for item: String in ["room_key", "school_key", "red_boot", "red_coat", "child_drawing", "voice_tape"]:
		GameState.add_item(item)
	for flag: String in ["villager_route", "phone_buzzed", "played_tape", "nb_room_seen", "found_notebooks"]:
		GameState.set_flag(flag)
	go_to("chapel")


func go_to(room_id: String) -> void:
	if _busy:
		return
	if not RoomData.ROOMS.has(room_id):
		push_error("go_to: unknown room '%s'" % room_id)
		return
	_busy = true
	await Fade.to_black(FADE_TIME)
	_load_room(room_id)
	await Fade.from_black(FADE_TIME)
	_busy = false
	_current.on_shown()


func _load_room(room_id: String) -> void:
	var actual: String = RoomData.resolve(room_id)
	if _current:
		_current.queue_free()
		_current = null
	var room: RoomView = ROOM_SCENE.instantiate()
	room.room_id = actual
	room.exit_requested.connect(go_to)
	add_child(room)
	_current = room
	GameState.enter_room(actual)
