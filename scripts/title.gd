extends Control
## Title screen: Start, Credits, Options, Quit.

const DEV_NAME: String = "Abir"           
const MAIN_SCENE: String = "res://scenes/main.tscn"
const ART_PATH: String = "res://art/title.png" 

var _center: CenterContainer
var _menu: VBoxContainer
var _options: OptionsPanel
var _credits: Control
var _credits_text: RichTextLabel
var _credits_tween: Tween
var _fade: ColorRect
var _start_button: Button
var _starting: bool = false


func _ready() -> void:
	PauseMenu.enabled = false
	Notebook.set_enabled(false)
	_build()
	_show_menu()
	Sfx.play_ambient("wind", -10.0)
	var t := create_tween()
	t.tween_property(_fade, "color:a", 0.0, 1.5)


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.025, 0.035)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	if ResourceLoader.exists(ART_PATH):
		var art := TextureRect.new()
		art.texture = load(ART_PATH) as Texture2D
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.modulate = Color(1, 1, 1, 0.5)
		art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(art)

	_center = CenterContainer.new()
	_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_center)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.custom_minimum_size = Vector2(300, 0)
	_center.add_child(col)

	col.add_child(MenuUI.label("SHEETWATER", 40, Color(0.88, 0.9, 0.93)))
	col.add_child(MenuUI.label("Day 1.", 11, Color(0.5, 0.54, 0.6)))
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 22)
	col.add_child(gap)

	_menu = VBoxContainer.new()
	_menu.add_theme_constant_override("separation", 2)
	col.add_child(_menu)

	var start_text: String = "Start"
	if Meta.endings_seen.size() > 0:
		start_text = "Arrive again"
	_start_button = MenuUI.button(start_text)
	_start_button.pressed.connect(_on_start)
	_menu.add_child(_start_button)

	var options_button := MenuUI.button("Options")
	options_button.pressed.connect(_show_options)
	_menu.add_child(options_button)

	var credits_button := MenuUI.button("Credits")
	credits_button.pressed.connect(_open_credits)
	_menu.add_child(credits_button)

	if not OS.has_feature("web"):
		var quit_button := MenuUI.button("Quit")
		quit_button.pressed.connect(func() -> void: get_tree().quit())
		_menu.add_child(quit_button)

	_options = OptionsPanel.new()
	_options.visible = false
	_options.closed.connect(_show_menu)
	col.add_child(_options)

	# Footer: content note + endings found.
	var note := Label.new()
	note.text = "Content note: the death of a child; a suicide attempt.\nHeadphones recommended."
	if Meta.endings_seen.size() > 0:
		note.text += "\nEndings found: %d / %d" % [Meta.endings_seen.size(), Meta.TOTAL_ENDINGS]
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	note.add_theme_font_size_override("font_size", 8)
	note.add_theme_color_override("font_color", Color(0.45, 0.48, 0.54))
	note.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	note.offset_left = 20.0
	note.offset_right = -20.0
	note.offset_top = -44.0
	note.offset_bottom = -6.0
	add_child(note)

	_build_credits()

	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 1)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fade)


func _build_credits() -> void:
	_credits = Control.new()
	_credits.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_credits.clip_contents = true
	_credits.visible = false
	add_child(_credits)

	var cbg := ColorRect.new()
	cbg.color = Color(0.02, 0.025, 0.035)
	cbg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_credits.add_child(cbg)

	_credits_text = RichTextLabel.new()
	_credits_text.bbcode_enabled = true
	_credits_text.fit_content = true
	_credits_text.scroll_active = false
	_credits_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_credits_text.add_theme_font_size_override("normal_font_size", 12)
	_credits_text.add_theme_font_size_override("bold_font_size", 12)
	_credits_text.add_theme_color_override("default_color", Color(0.85, 0.87, 0.9))
	_credits_text.custom_minimum_size = Vector2(420, 0)
	_credits_text.size = Vector2(420, 10)
	_credits_text.text = _credits_bbcode()
	_credits.add_child(_credits_text)

	var back := MenuUI.button("Back", 12)
	back.pressed.connect(_show_menu)
	back.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 10)
	_credits.add_child(back)


func _credits_bbcode() -> String:
	var dim: String = "[color=#7d8590]"
	var lines: PackedStringArray = PackedStringArray([
		"[center]",
		"[font_size=28]SHEETWATER[/font_size]", "", "",
		dim + "Written, designed and programmed by[/color]", DEV_NAME, "", "",
		dim + "Art[/color]",
		"Generated with Google Gemini,",
		"processed and arranged by " + DEV_NAME, "", "",
		dim + "Sound[/color]",
		"Generated with code,", "written with Claude (Anthropic)", "", "",
		dim + "Made with[/color]",
		"Godot Engine 4.6", "", "",
		"", "Thank you for playing.", "", "",
		dim + "If this touched something heavy,[/color]",
		dim + "you don't have to carry it alone.[/color]",
		dim + "Please reach out to someone you trust,[/color]",
		dim + "or a local crisis line.[/color]",
		"[/center]",
	])
	return "\n".join(lines)


func _show_menu() -> void:
	if _credits_tween != null and _credits_tween.is_valid():
		_credits_tween.kill()
	_credits.visible = false
	_center.visible = true
	_options.visible = false
	_menu.visible = true
	_start_button.grab_focus()


func _show_options() -> void:
	_menu.visible = false
	_options.visible = true


func _open_credits() -> void:
	_center.visible = false
	_credits.visible = true
	var view: Vector2 = get_viewport_rect().size
	_credits_text.size = Vector2(420, 10)
	_credits_text.position = Vector2((view.x - 420.0) / 2.0, view.y)
	await get_tree().process_frame
	var h: float = maxf(float(_credits_text.get_content_height()), 200.0)
	var duration: float = (h + view.y) / 24.0
	_credits_tween = create_tween()
	_credits_tween.tween_property(_credits_text, "position:y", -h, duration)
	_credits_tween.finished.connect(_show_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (_credits.visible or _options.visible):
		get_viewport().set_input_as_handled()
		_show_menu()


func _on_start() -> void:
	if _starting:
		return
	_starting = true
	var t := create_tween()
	t.tween_property(_fade, "color:a", 1.0, 1.0)
	await t.finished
	Sfx.stop_ambient()
	get_tree().change_scene_to_file(MAIN_SCENE)
