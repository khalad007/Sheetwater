class_name RoomView
extends Control
## One room, built entirely from RoomData.
## Set `room_id` BEFORE adding it to the tree.

signal exit_requested(room_id: String)

var room_id: String = ""

var _data: Dictionary = {}
var _hotspots: Array[Hotspot] = []
var _hovered_spot: Hotspot
var _hover_label: Label
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
	_build_girl()
	_build_hotspots()
	_build_hover_label()
	_build_caption()
	GameState.flag_changed.connect(_refresh_hotspots.unbind(2))
	GameState.item_added.connect(_refresh_hotspots.unbind(1))
	Dialogue.finished.connect(_refresh_hotspots)
	_refresh_hotspots()
	
func _build_girl() -> void:
	if not _data.has("girl"):
		return
	var g: Dictionary = _data["girl"]
	if not GameState.check_all(g.get("show_if", [])):
		return
	var pos: Array = g["pos"]
	var girl := Girl.new()
	girl.position = Vector2(pos[0], pos[1])
	add_child(girl)


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
		spot.hover_changed.connect(_on_hover_changed)
		add_child(spot)
		_hotspots.append(spot)


func _build_hover_label() -> void:
	_hover_label = Label.new()
	_hover_label.position = Vector2(0, 6)
	_hover_label.size = Vector2(640, 20)
	_hover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hover_label.add_theme_font_size_override("font_size", 12)
	_hover_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_hover_label.add_theme_constant_override("shadow_offset_x", 1)
	_hover_label.add_theme_constant_override("shadow_offset_y", 1)
	_hover_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hover_label)


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


func _refresh_hotspots() -> void:
	for spot in _hotspots:
		spot.refresh()
	# No hover feedback while a conversation covers the room.
	if Dialogue.active:
		_hovered_spot = null
		for spot in _hotspots:
			spot.set_hovered(false)
		_update_hover_label()
		return
	# A hotspot may have appeared/disappeared under a stationary mouse.
	_hovered_spot = null
	var mouse: Vector2 = get_local_mouse_position()
	for spot in _hotspots:
		if spot.visible and Rect2(spot.position, spot.size).has_point(mouse):
			_hovered_spot = spot
	for spot in _hotspots:
		spot.set_hovered(spot == _hovered_spot)
	_update_hover_label()


func _on_hover_changed(spot: Hotspot, is_hovered: bool) -> void:
	if is_hovered:
		_hovered_spot = spot
	elif _hovered_spot == spot:
		_hovered_spot = null
	_update_hover_label()


func _update_hover_label() -> void:
	if _hovered_spot:
		_hover_label.text = str(_hovered_spot.data.get("label", ""))
	else:
		_hover_label.text = ""


func _on_hotspot_activated(spot_data: Dictionary) -> void:
	if Dialogue.active:
		return
	if not GameState.check_all(spot_data.get("needs", [])):
		show_caption(str(spot_data.get("locked_text", "Not yet.")))
		return
	if spot_data.has("sets"):
		GameState.set_flag(spot_data["sets"])
	if spot_data.has("gives"):
		GameState.add_item(spot_data["gives"])
	if spot_data.has("exit"):
		exit_requested.emit(spot_data["exit"])
	elif spot_data.has("beat"):
		_caption_bg.hide()
		Dialogue.play(spot_data["beat"])
	elif spot_data.has("text"):
		show_caption(spot_data["text"])
