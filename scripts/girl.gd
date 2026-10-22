class_name Girl
extends Control
## The faceless girl at the edge of the frame. Built by RoomView from a room's
## "girl" data. She shows one layer per found piece (see GirlData).
## She fades in shortly after the room appears, fades out when the cursor comes
## near, and returns a couple of seconds after it leaves.
## With the voice piece she says one line (sound "girl_voice") once per room visit.

const BOX: Vector2 = Vector2(48, 96)
const APPEAR_DELAY: float = 1.5
const FADE_TIME: float = 0.8
const SHY_DISTANCE: float = 60.0
const RETURN_DELAY: float = 2.0
const VOICE_SOUND: String = "girl_voice"

var _time: float = 0.0
var _shy_left: float = 0.0
var _voice_done: bool = false
var _base_tex: Texture2D
var _layers: Array = []   # each: {id, tex, offset}


func _ready() -> void:
	size = BOX
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	_base_tex = _try_load(GirlData.BASE_ART)
	GameState.item_added.connect(_on_item_added)
	_rebuild()


func _on_item_added(_item_id: String) -> void:
	_rebuild()


func _try_load(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _rebuild() -> void:
	_layers.clear()
	for f: Dictionary in GirlData.FEATURES:
		if not GameState.has_item(f["item"]):
			continue
		var offset: Array = f.get("offset", [0, 0])
		_layers.append({
			"id": f["id"],
			"tex": _try_load(f.get("art", "")),
			"offset": Vector2(offset[0], offset[1]),
		})
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	var distance: float = (get_local_mouse_position() - BOX / 2.0).length()
	if distance < SHY_DISTANCE:
		_shy_left = RETURN_DELAY
	else:
		_shy_left = maxf(0.0, _shy_left - delta)
	var target: float = 1.0 if (_time >= APPEAR_DELAY and _shy_left <= 0.0) else 0.0
	modulate.a = move_toward(modulate.a, target, delta / FADE_TIME)
	if not _voice_done and modulate.a > 0.6 and GameState.has_item(GirlData.VOICE_ITEM):
		_voice_done = true
		Sfx.play(VOICE_SOUND, -8.0)


func _draw() -> void:
	if _base_tex:
		draw_texture(_base_tex, Vector2.ZERO)
	else:
		_draw_base_placeholder()
	for layer: Dictionary in _layers:
		if layer["tex"]:
			draw_texture(layer["tex"], layer["offset"])
		else:
			_draw_placeholder(layer["id"])


func _draw_base_placeholder() -> void:
	var grey := Color("#7d8591")
	draw_circle(Vector2(24, 17), 12.0, grey)                      # blank head, on purpose
	draw_rect(Rect2(14, 30, 20, 38), grey.darkened(0.15))         # dress
	draw_rect(Rect2(17, 68, 5, 22), grey.darkened(0.3))           # legs
	draw_rect(Rect2(26, 68, 5, 22), grey.darkened(0.3))


func _draw_placeholder(id: String) -> void:
	match id:
		"feet":
			draw_rect(Rect2(15, 84, 9, 9), Color("#b3322c"))
			draw_rect(Rect2(25, 84, 9, 9), Color("#b3322c"))
		"coat":
			draw_rect(Rect2(11, 30, 26, 40), Color("#b3322c"))
			draw_line(Vector2(24, 30), Vector2(24, 70), Color("#7a1f1b"), 1.0)
		"hands":
			draw_rect(Rect2(8, 48, 5, 6), Color("#e3cdb8"))
			draw_rect(Rect2(35, 48, 5, 6), Color("#e3cdb8"))
