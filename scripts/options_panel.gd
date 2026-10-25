class_name OptionsPanel
extends VBoxContainer
## Volume + fullscreen. Used by the title screen and the pause menu.

signal closed

var _volume_label: Label
var _slider: HSlider
var _fullscreen_button: Button


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	alignment = BoxContainer.ALIGNMENT_CENTER
	custom_minimum_size = Vector2(240, 0)

	add_child(MenuUI.label("OPTIONS", 14, MenuUI.COL_DIM))

	_volume_label = MenuUI.label("", 12, MenuUI.COL_HOT)
	add_child(_volume_label)

	_slider = HSlider.new()
	_slider.min_value = 0.0
	_slider.max_value = 100.0
	_slider.step = 5.0
	_slider.custom_minimum_size = Vector2(200, 16)
	_slider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_slider.value_changed.connect(_on_volume)
	_slider.drag_ended.connect(_on_drag_ended)
	add_child(_slider)

	_fullscreen_button = MenuUI.button("", 12)
	_fullscreen_button.pressed.connect(_on_fullscreen)
	add_child(_fullscreen_button)

	var back := MenuUI.button("Back", 12)
	back.pressed.connect(_on_back)
	add_child(back)

	visibility_changed.connect(_sync)
	_sync()


func _sync() -> void:
	if _slider == null:
		return
	_slider.set_value_no_signal(roundf(Meta.master_volume * 100.0))
	_volume_label.text = "Volume  %d%%" % int(roundf(Meta.master_volume * 100.0))
	_fullscreen_button.text = "Fullscreen: " + ("on" if Meta.fullscreen else "off")
	if is_visible_in_tree():
		_slider.grab_focus()


func _on_volume(v: float) -> void:
	Meta.master_volume = v / 100.0
	Meta.apply_volume()
	_volume_label.text = "Volume  %d%%" % int(v)


func _on_drag_ended(_changed: bool) -> void:
	Meta.save_data()
	Sfx.play("paper_rustle")   # so you can hear the new level


func _on_fullscreen() -> void:
	Meta.set_fullscreen(not Meta.fullscreen)
	_sync()


func _on_back() -> void:
	Meta.save_data()
	closed.emit()
