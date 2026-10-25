extends CanvasLayer
## Esc pause menu. Autoload name: PauseMenu

var enabled: bool = true   # the title screen turns this off

var _root: Control
var _menu: VBoxContainer
var _options: OptionsPanel
var _resume_button: Button


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Keep sound running while paused so you can hear the volume change.
	Sfx.process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_root.visible = false


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(240, 0)
	center.add_child(col)

	_menu = VBoxContainer.new()
	_menu.add_theme_constant_override("separation", 4)
	col.add_child(_menu)
	_menu.add_child(MenuUI.label("PAUSED", 16, MenuUI.COL_DIM))

	_resume_button = MenuUI.button("Resume")
	_resume_button.pressed.connect(_close)
	_menu.add_child(_resume_button)

	var options_button := MenuUI.button("Options")
	options_button.pressed.connect(_show_options)
	_menu.add_child(options_button)

	if not OS.has_feature("web"):
		var quit_button := MenuUI.button("Quit game")
		quit_button.pressed.connect(func() -> void: get_tree().quit())
		_menu.add_child(quit_button)

	_options = OptionsPanel.new()
	_options.visible = false
	_options.closed.connect(_show_menu)
	col.add_child(_options)


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or key.keycode != KEY_ESCAPE:
		return
	if not enabled:
		return
	get_viewport().set_input_as_handled()
	# This autoload receives keys before Notebook. Let Esc close it first.
	if not _root.visible and Notebook.is_open():
		Notebook.close()
		return
	if not _root.visible:
		_open()
	elif _options.visible:
		_show_menu()
	else:
		_close()


func _open() -> void:
	get_tree().paused = true
	_root.visible = true
	_show_menu()


func _close() -> void:
	Meta.save_data()
	_root.visible = false
	get_tree().paused = false


func _show_menu() -> void:
	_options.visible = false
	_menu.visible = true
	_resume_button.grab_focus()


func _show_options() -> void:
	_menu.visible = false
	_options.visible = true
