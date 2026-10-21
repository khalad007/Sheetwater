class_name Hotspot
extends Control
## A clickable rectangle. All behaviour lives in `data` (see room_data.gd).
## refresh() re-evaluates visibility and lock state from GameState.

signal activated(data: Dictionary)
signal hover_changed(spot: Hotspot, is_hovered: bool)

var data: Dictionary = {}
var hovered: bool = false
var unlocked: bool = true
var debug: bool = false:
	set(value):
		debug = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))


func _on_hover(is_hovered: bool) -> void:
	hovered = is_hovered
	queue_redraw()
	hover_changed.emit(self, is_hovered)


func set_hovered(value: bool) -> void:
	hovered = value
	queue_redraw()


func refresh() -> void:
	var gives: String = data.get("gives", "")
	var shown: bool = GameState.check_all(data.get("show_if", []))
	var hidden: bool = data.has("hide_if") and GameState.check_all(data["hide_if"])
	if gives != "" and GameState.has_item(gives):
		hidden = true
	var should_show: bool = shown and not hidden
	if visible and not should_show:
		hovered = false
	visible = should_show
	unlocked = GameState.check_all(data.get("needs", []))
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if unlocked else Control.CURSOR_FORBIDDEN
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		activated.emit(data)


func _draw() -> void:
	if not (hovered or debug):
		return
	# White outline when usable, reddish when locked. Placeholder look until we have art.
	var tint := Color(1, 1, 1) if unlocked else Color(1.0, 0.55, 0.55)
	var area := Rect2(Vector2.ZERO, size)
	draw_rect(area, Color(tint, 0.10 if hovered else 0.04), true)
	draw_rect(area, Color(tint, 0.9 if hovered else 0.35), false, 1.0)
	if debug:
		var font: Font = ThemeDB.fallback_font
		draw_string(font, Vector2(3, 12), str(data.get("label", "")),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
