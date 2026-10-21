class_name RoomView
extends Control
## One room, built entirely from RoomData.
## Set `room_id` BEFORE adding it to the tree.

signal exit_requested(room_id: String)

var room_id: String = ""

var _data: Dictionary = {}
var _hotspots: Array[Hotspot] = []
var _caption_bg: ColorRect
var _caption_label: Label
var _caption_timer: Timer
var _debug: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not RoomData.ROOMS.has(room_id):
		push_error("RoomView: unknown room '%s'" % room_id)
		return
	_data = RoomData.ROOMS[room_id]
	_build_background()
	_build_hotspots()
	_build_caption()


func _unhandled_key_input(event: InputEvent) -> void:
	# F2 outlines every hotspot with its label. Only in editor/debug builds.
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.keycode == KEY_F2 and OS.is_debug_build():
		_debug = not _debug
		for h in _hotspots:
			h.debug = _debug


func _build_background() -> void:
	var fill := ColorRect.new()
	fill.color = Color(str(_data.get("color", "#111111")))
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fill)
	fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg_path: String = _data.get("bg", "")
	if bg_path != "" and ResourceLoader.exists(bg_path):
		var pic := TextureRect.new()
		pic.texture = load(bg_path) as Texture2D
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_SCALE
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pic)
		pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		var title := Label.new()
		title.text = str(_data.get("title", room_id)).to_upper()
		title.modulate = Color(1, 1, 1, 0.25)
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title.position = Vector2(12, 8)
		add_child(title)


func _build_hotspots() -> void:
	for h: Dictionary in _data.get("hotspots", []):
		var r: Array = h["rect"]
		var spot := Hotspot.new()
		spot.data = h
		spot.position = Vector2(r[0], r[1])
		spot.size = Vector2(r[2], r[3])
		spot.activated.connect(_on_hotspot_activated)
		add_child(spot)
		_hotspots.append(spot)


func _build_caption() -> void:
	_caption_bg = ColorRect.new()
	_caption_bg.color = Color(0, 0, 0, 0.75)
	_caption_bg.position = Vector2(0, 312)
	_caption_bg.size = Vector2(640, 48)
	_caption_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption_bg.hide()
	add_child(_caption_bg)

	_caption_label = Label.new()
	_caption_label.position = Vector2(10, 4)
	_caption_label.size = Vector2(620, 40)
	_caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption_label.add_theme_font_size_override("font_size", 14)
	_caption_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption_bg.add_child(_caption_label)

	_caption_timer = Timer.new()
	_caption_timer.one_shot = true
	_caption_timer.timeout.connect(_caption_bg.hide)
	add_child(_caption_timer)


func show_caption(text: String) -> void:
	_caption_label.text = text
	_caption_bg.show()
	_caption_timer.start(maxf(2.5, text.length() * 0.05))


func _on_hotspot_activated(spot_data: Dictionary) -> void:
	if spot_data.has("exit"):
		exit_requested.emit(spot_data["exit"])
	elif spot_data.has("text"):
		show_caption(spot_data["text"])
