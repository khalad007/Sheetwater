extends CanvasLayer
## Notebook: items + notes panel and pickup toasts. Autoload name: Notebook.
##   N toggles it, Esc closes it, the top-right button opens it.
##   Notebook.set_enabled(false) hides it completely (for title screen / endings).
## Content comes from NotebookData. Keep the top-right corner of rooms free of hotspots.
## TODO (step 14): call reset() when a new loop starts.

const PANEL_POS: Vector2 = Vector2(60, 30)
const PANEL_SIZE: Vector2 = Vector2(520, 300)

var _theme: Theme
var _button: Button
var _toast: Label
var _toast_tween: Tween
var _overlay: Control
var _tab_items: Button
var _tab_notes: Button
var _items_view: HBoxContainer
var _items_box: VBoxContainer
var _detail: Label
var _notes_scroll: ScrollContainer
var _notes_box: VBoxContainer
var _seen_notes: Array[String] = []
var _open: bool = false
var _enabled: bool = true


func _ready() -> void:
	layer = 50   # above rooms, below Fade (100)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_theme = Theme.new()
	_theme.default_font_size = 12
	_build_button()
	_build_toast()
	_build_overlay()
	GameState.item_added.connect(_on_item_added)
	GameState.flag_changed.connect(func(_flag, _value): _check_new_notes(true))


# ---------- public ----------

func set_enabled(value: bool) -> void:
	_enabled = value
	_button.visible = value
	if not value:
		close()


func reset() -> void:
	_seen_notes.clear()
	close()


func toggle() -> void:
	if _open:
		close()
	else:
		open()


func open() -> void:
	if not _enabled or _open:
		return
	_refresh()
	_tab_items.button_pressed = true
	_show_tab(true)
	_overlay.show()
	_open = true


func is_open() -> bool:
	return _open


func close() -> void:
	_overlay.hide()
	_open = false


# ---------- input ----------

func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_N:
		toggle()
		get_viewport().set_input_as_handled()
	elif key.keycode == KEY_ESCAPE and _open:
		close()
		get_viewport().set_input_as_handled()


func _on_dim_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		close()


# ---------- game events ----------

func _on_item_added(item_id: String) -> void:
	_check_new_notes(false)   # record silently; the item toast wins
	_show_toast("Found: " + _item_name(item_id))


func _check_new_notes(announce: bool) -> void:
	var fresh: bool = false
	for n: Dictionary in NotebookData.NOTES:
		var nid: String = n["id"]
		if _seen_notes.has(nid):
			continue
		if GameState.check_all(n.get("show_if", [])):
			_seen_notes.append(nid)
			fresh = true
	if fresh and announce:
		_show_toast("Notebook updated")


func _item_name(item_id: String) -> String:
	if not NotebookData.ITEMS.has(item_id):
		push_warning("Notebook: no ITEMS entry for '%s'" % item_id)
		return item_id.capitalize()
	var info: Dictionary = NotebookData.ITEMS[item_id]
	return str(info.get("name", item_id))


# ---------- building the UI ----------

func _flat(color: Color, margin: float, border: Color = Color(0, 0, 0, 0), border_w: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_content_margin_all(margin)
	if border_w > 0:
		sb.border_color = border
		sb.set_border_width_all(border_w)
	return sb


func _build_button() -> void:
	_button = Button.new()
	_button.theme = _theme
	_button.text = "Notebook (N)"
	_button.focus_mode = Control.FOCUS_NONE
	_button.pressed.connect(toggle)
	add_child(_button)
	_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 6)


func _build_toast() -> void:
	_toast = Label.new()
	_toast.theme = _theme
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_stylebox_override("normal", _flat(Color(0, 0, 0, 0.75), 5))
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.hide()
	add_child(_toast)


func _show_toast(text: String) -> void:
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast.text = text
	_toast.reset_size()
	_toast.position = Vector2((640.0 - _toast.size.x) / 2.0, 30.0)
	_toast.modulate.a = 1.0
	_toast.show()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(2.2)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.5)
	_toast_tween.tween_callback(_toast.hide)


func _make_tab(label: String, group: ButtonGroup, parent: Control) -> Button:
	var b := Button.new()
	b.text = label
	b.toggle_mode = true
	b.button_group = group
	b.focus_mode = Control.FOCUS_NONE
	parent.add_child(b)
	return b


func _build_overlay() -> void:
	_overlay = Control.new()
	_overlay.theme = _theme
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.hide()
	add_child(_overlay)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect(_on_dim_input)
	_overlay.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", _flat(Color("#14161c"), 0, Color("#5a6070"), 1))
	panel.position = PANEL_POS
	panel.size = PANEL_SIZE
	_overlay.add_child(panel)

	var title := Label.new()
	title.text = "NOTEBOOK"
	title.position = Vector2(14, 10)
	panel.add_child(title)

	var tabs := HBoxContainer.new()
	tabs.position = Vector2(14, 34)
	panel.add_child(tabs)
	var group := ButtonGroup.new()
	_tab_items = _make_tab("Items", group, tabs)
	_tab_notes = _make_tab("Notes", group, tabs)
	_tab_items.button_pressed = true
	_tab_items.pressed.connect(_show_tab.bind(true))
	_tab_notes.pressed.connect(_show_tab.bind(false))

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.position = Vector2(PANEL_SIZE.x - 36, 8)
	close_btn.pressed.connect(close)
	panel.add_child(close_btn)

	# Items tab: list on the left, description on the right.
	_items_view = HBoxContainer.new()
	_items_view.position = Vector2(14, 68)
	_items_view.size = Vector2(492, 220)
	_items_view.add_theme_constant_override("separation", 14)
	panel.add_child(_items_view)

	var list_scroll := ScrollContainer.new()
	list_scroll.custom_minimum_size = Vector2(170, 0)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_items_view.add_child(list_scroll)
	_items_box = VBoxContainer.new()
	_items_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.add_child(_items_box)

	_detail = Label.new()
	_detail.custom_minimum_size = Vector2(300, 0)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_items_view.add_child(_detail)

	# Notes tab.
	_notes_scroll = ScrollContainer.new()
	_notes_scroll.position = Vector2(14, 68)
	_notes_scroll.size = Vector2(492, 220)
	_notes_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_notes_scroll.hide()
	panel.add_child(_notes_scroll)
	_notes_box = VBoxContainer.new()
	_notes_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_notes_box.add_theme_constant_override("separation", 8)
	_notes_scroll.add_child(_notes_box)


func _show_tab(items: bool) -> void:
	_items_view.visible = items
	_notes_scroll.visible = not items


# ---------- filling the UI ----------

func _refresh() -> void:
	for c in _items_box.get_children():
		c.queue_free()
	if GameState.items.is_empty():
		_detail.text = "You haven't found anything yet."
	else:
		for id: String in GameState.items:
			var btn := Button.new()
			btn.text = _item_name(id)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.focus_mode = Control.FOCUS_NONE
			btn.pressed.connect(_select_item.bind(id))
			_items_box.add_child(btn)
		_select_item(GameState.items[0])

	for c in _notes_box.get_children():
		c.queue_free()
	var any: bool = false
	for n: Dictionary in NotebookData.NOTES:
		if GameState.check_all(n.get("show_if", [])):
			any = true
			_notes_box.add_child(_make_note_label(str(n["text"])))
	if not any:
		_notes_box.add_child(_make_note_label("Empty pages."))


func _make_note_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(470, 0)
	return l


func _select_item(item_id: String) -> void:
	var info: Dictionary = NotebookData.ITEMS.get(item_id, {})
	_detail.text = "%s\n\n%s" % [_item_name(item_id), str(info.get("desc", ""))]
