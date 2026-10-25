extends CanvasLayer
## Ending cards. Autoload name: Ending. Content comes from EndingData.
##   Ending.start("look")   (normally triggered by a beat with "ending": "look")
## Click / Space / Enter / Z skips the slow reveal and shows the buttons.
## "loop" fades out, calls GameState.new_loop(), resets the Notebook and reloads Main.

var active: bool = false

var _theme: Theme
var _root: Control
var _lines_box: VBoxContainer
var _title: Label
var _subtitle: Label
var _buttons: HBoxContainer
var _tween: Tween
var _labels: Array[Label] = []
var _buttons_shown: bool = false
var _leaving: bool = false


func _ready() -> void:
	layer = 90   # above Dialogue (40) and Notebook (50), below Fade (100)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_theme = Theme.new()
	_theme.default_font_size = 14
	_build_ui()


# ---------- public ----------

func start(id: String) -> void:
	if active:
		return
	if not EndingData.ENDINGS.has(id):
		push_error("Ending: unknown ending '%s'" % id)
		return
	active = true
	_leaving = false
	var e: Dictionary = EndingData.ENDINGS[id]
	GameState.record_ending(id)
	Notebook.set_enabled(false)
	Sfx.stop_ambient()
	await Fade.to_black(1.2)
	_populate(e)
	_root.show()
	await Fade.from_black(0.0)
	if e.has("sfx"):
		Sfx.play(str(e["sfx"]))
	_reveal()


# ---------- input ----------

func _on_root_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		_skip()


func _unhandled_key_input(event: InputEvent) -> void:
	if not active or not _root.visible:
		return
	var key := event as InputEventKey
	if key and key.pressed and not key.echo \
			and key.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_Z]:
		get_viewport().set_input_as_handled()
		_skip()


# ---------- flow ----------

func _populate(e: Dictionary) -> void:
	for c in _lines_box.get_children():
		c.queue_free()
	_labels.clear()
	for t: String in e.get("lines", []):
		var l := Label.new()
		l.text = t
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.custom_minimum_size = Vector2(480, 0)
		l.modulate.a = 0.0
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lines_box.add_child(l)
		_labels.append(l)
	_title.text = str(e.get("title", ""))
	_title.modulate.a = 0.0
	_subtitle.text = str(e.get("subtitle", ""))
	_subtitle.modulate.a = 0.0
	for c in _buttons.get_children():
		c.queue_free()
	for b: Dictionary in e.get("buttons", []):
		var action: String = str(b.get("do", ""))
		if action == "quit" and OS.has_feature("web"):
			continue   # a browser tab can't quit
		var btn := Button.new()
		btn.text = str(b["text"])
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_button.bind(action))
		_buttons.add_child(btn)
	_buttons.modulate.a = 0.0
	_buttons.hide()
	_buttons_shown = false


func _reveal() -> void:
	_tween = create_tween()
	_tween.tween_interval(0.8)
	for l in _labels:
		_tween.tween_property(l, "modulate:a", 1.0, 1.5)
		_tween.tween_interval(1.2)
	_tween.tween_property(_title, "modulate:a", 1.0, 1.5)
	_tween.tween_property(_subtitle, "modulate:a", 1.0, 1.0)
	_tween.tween_interval(0.6)
	_tween.tween_callback(_show_buttons)


func _skip() -> void:
	if not active or _buttons_shown or _leaving or not _root.visible:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	for l in _labels:
		l.modulate.a = 1.0
	_title.modulate.a = 1.0
	_subtitle.modulate.a = 1.0
	_show_buttons()


func _show_buttons() -> void:
	if _buttons_shown:
		return
	_buttons_shown = true
	_buttons.show()
	create_tween().tween_property(_buttons, "modulate:a", 1.0, 0.6)


func _on_button(action: String) -> void:
	if _leaving:
		return
	match action:
		"loop":
			_begin_loop()
		"quit":
			get_tree().quit()
		_:
			push_warning("Ending: unknown button action '%s'" % action)


func _begin_loop() -> void:
	_leaving = true
	await Fade.to_black(0.9)
	_root.hide()
	active = false
	GameState.new_loop()
	Notebook.reset()
	Notebook.set_enabled(true)
	get_tree().reload_current_scene()


# ---------- building the UI ----------

func _build_ui() -> void:
	_root = Control.new()
	_root.theme = _theme
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.gui_input.connect(_on_root_input)
	_root.hide()
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var black := ColorRect.new()
	black.color = Color.BLACK
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(black)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_lines_box = VBoxContainer.new()
	_lines_box.position = Vector2(80, 50)
	_lines_box.size = Vector2(480, 190)
	_lines_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_lines_box.add_theme_constant_override("separation", 14)
	_lines_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_lines_box)

	_title = Label.new()
	_title.position = Vector2(0, 252)
	_title.size = Vector2(640, 30)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 24)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_title)

	_subtitle = Label.new()
	_subtitle.position = Vector2(0, 286)
	_subtitle.size = Vector2(640, 18)
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.add_theme_font_size_override("font_size", 11)
	_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_subtitle)

	_buttons = HBoxContainer.new()
	_buttons.position = Vector2(0, 316)
	_buttons.size = Vector2(640, 32)
	_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	_buttons.add_theme_constant_override("separation", 16)
	_root.add_child(_buttons)
