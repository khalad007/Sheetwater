class_name MenuUI
extends RefCounted
## Shared look for every menu: dim grey text that turns white on hover/focus.

const COL_DIM: Color = Color(0.62, 0.66, 0.72)
const COL_HOT: Color = Color(0.95, 0.96, 0.98)
const COL_OFF: Color = Color(0.30, 0.32, 0.36)


static func button(text: String, font_size: int = 14) -> Button:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_size_override("font_size", font_size)
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", COL_DIM)
	b.add_theme_color_override("font_hover_color", COL_HOT)
	b.add_theme_color_override("font_focus_color", COL_HOT)
	b.add_theme_color_override("font_pressed_color", COL_HOT)
	b.add_theme_color_override("font_disabled_color", COL_OFF)
	return b


static func label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l
