extends Control
## Host: owns exactly one room at a time and swaps it on request.

const ROOM_SCENE: PackedScene = preload("res://scenes/room.tscn")
const START_ROOM: String = "bus_stop"

var _current: RoomView


func _ready() -> void:
	go_to(START_ROOM)


func go_to(room_id: String) -> void:
	if not RoomData.ROOMS.has(room_id):
		push_error("go_to: unknown room '%s'" % room_id)
		return
	if _current:
		_current.queue_free()
		_current = null
	var room: RoomView = ROOM_SCENE.instantiate()
	room.room_id = room_id
	room.exit_requested.connect(go_to)
	add_child(room)
	_current = room
