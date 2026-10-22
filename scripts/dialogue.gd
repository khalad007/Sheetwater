extends CanvasLayer
## Plays "beats" from StoryData over the current room. Autoload name: Dialogue.
##   Dialogue.play("beat_id")     start a conversation (ignored if one is running)
##   await Dialogue.finished      wait until it ends
##   Dialogue.active              true while a conversation is on screen
## Left-click, Space, Enter or Z: finish the typing, then go to the next beat.
## While active, the overlay swallows mouse input (hotspots can't be clicked)
## and the Notebook is disabled.

signal finished

const CHARS_PER_SEC: float = 45.0

var active: bool = false

var _beat: Dictionary = {}
var _next_id: String = ""
var _typing: bool = false
var _awaiting_choice: bool = false
var _progress: float = 0.0
var _theme: Theme
var _root: Control
var _speaker: Label
var _text: Label
var _hint: Label
var _choices: VBoxContainer


func _ready() -> void:
	layer = 40   # above rooms, below Notebook (50) and Fade (100)
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	_theme = Theme.new()
	_theme.default_font_size = 14
	_build_ui()


# ---------- public ----------

func play(beat_id: String) -> void:
	if active:
		return
	if not StoryData.BEATS.has(beat_id):
		push_error("Dialogue: unknown beat '%s'" % beat_id)
		return
	active = true
	Notebook.set_enabled(false)
	_root.show()
	_show_beat(beat_id)


# ---------- input ----------

func _on_root_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		_advance()


func _unhandled_key_input(event: InputEvent) -> void:
	if not active:
		return
	var key := event as InputEventKey
	if key and key.pressed and not key.echo \
			and key.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_Z]:
		get_viewport().set_input_as_handled()
		_advance()


# ---------- flow ----------

func _show_beat(beat_id: String) -> void:
	if not StoryData.BEATS.has(beat_id):
		push_error("Dialogue: unknown beat '%s'" % beat_id)
		_end()
		return
	_beat = StoryData.BEATS[beat_id]
	if _beat.has("sets"):
		GameState.set_flag(_beat["sets"])
	if _beat.has("gives"):
		GameState.add_item(_beat["gives"])
	if _beat.has("sfx"):
		Sfx.play(_beat["sfx"])
	_next_id = _beat.get("next", "")
	_clear_choices()
	_awaiting_choice = false
	var who: String = _beat.get("speaker", "")
	_speaker.text = who
	_speaker.visible = who != ""
	_text.text = _beat.get("text", "")
	_text.visible_characters = 0
	_progress = 0.0
	_hint.hide()
	_typing = true
	set_process(true)


func _process(delta: float) -> void:
	if not _typing:
		return
	_progress += delta * CHARS_PER_SEC
	_text.visible_characters = int(_progress)
	if int(_progress) >= _text.text.length():
		_finish_typing()


func _finish_typing() -> void:
	_typing = false
	set_process(false)
	_text.visible_characters = -1
	var choices: Array = _beat.get("choices", [])
	if choices.size() > 0 and _show_choices(choices):
		_awaiting_choice = true
	else:
		_hint.show()


func _advance() -> void:
	if _awaiting_choice:
		return
	if _typing:
		_finish_typing()
		return
	if _next_id != "":
		_show_beat(_next_id)
	else:
		_end()


func _show_choices(choices: Array) -> bool:
	var shown: int = 0
	for c: Dictionary in choices:
		if not GameState.check_all(c.get("needs", [])):
			continue
		var b := Button.new()
		b.text = str(c["text"])
		b.focus_mode = Control.FOCUS_NONE
		b.size_flags_horizontal = Control.SIZE_SHRINK_END
		b.pressed.connect(_on_choice.bind(c))
		_choices.add_child(b)
		shown += 1
	return shown > 0


func _on_choice(c: Dictionary) -> void:
	if c.has("sets"):
		GameState.set_flag(c["sets"])
	if c.has("gives"):
		GameState.add_item(c["gives"])
	_clear_choices()
	_awaiting_choice = false
	var next_id: String = c.get("next", "")
	if next_id != "":
		_show_beat(next_id)
	else:
		_end()


func _clear_choices() -> void:
	for child in _choices.get_children():
		child.queue_free()


func _end() -> void:
	active = false
	_typing = false
	_awaiting_choice = false
	set_process(false)
	_clear_choices()
	_root.hide()
	Notebook.set_enabled(true)
	finished.emit()


# ---------- building the UI ----------

func _flat(color: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = border
	sb.set_border_width_all(1)
	return sb


func _build_ui() -> void:
	_root = Control.new()
	_root.theme = _theme
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.gui_input.connect(_on_root_input)
	_root.hide()
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box := Panel.new()
	box.add_theme_stylebox_override("panel", _flat(Color(0.05, 0.06, 0.08, 0.92), Color("#5a6070")))
	box.position = Vector2(20, 258)
	box.size = Vector2(600, 92)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(box)

	_speaker = Label.new()
	_speaker.modulate = Color("#c9b98a")
	_speaker.position = Vector2(12, 6)
	_speaker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_speaker)

	_text = Label.new()
	_text.position = Vector2(12, 26)
	_text.size = Vector2(576, 58)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_text)

	_hint = Label.new()
	_hint.text = "click to continue"
	_hint.add_theme_font_size_override("font_size", 10)
	_hint.modulate = Color(1, 1, 1, 0.5)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.position = Vector2(388, 74)
	_hint.size = Vector2(200, 14)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.hide()
	box.add_child(_hint)

	# Choice buttons stack upward from just above the text box.
	_choices = VBoxContainer.new()
	_choices.alignment = BoxContainer.ALIGNMENT_END
	_choices.position = Vector2(20, 150)
	_choices.size = Vector2(600, 104)
	_choices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_choices)
