extends Control
## Host: owns exactly one room at a time and swaps it with a fade.

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
	if _current:
		_current.queue_free()
		_current = null
	var room: RoomView = ROOM_SCENE.instantiate()
	room.room_id = room_id
	room.exit_requested.connect(go_to)
	add_child(room)
	_current = room
	GameState.enter_room(room_id)
