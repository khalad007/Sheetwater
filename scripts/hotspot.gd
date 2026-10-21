class_name Hotspot
extends Control
## A clickable rectangle. All behaviour lives in `data` (see room_data.gd).

signal activated(data: Dictionary)

var data: Dictionary = {}
var hovered: bool = false
var debug: bool = false:
	set(value):
		debug = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	hovered = true
	queue_redraw()


func _on_mouse_exited() -> void:
	hovered = false
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		activated.emit(data)


func _draw() -> void:
	if not (hovered or debug):
		return
	var area := Rect2(Vector2.ZERO, size)
	draw_rect(area, Color(1, 1, 1, 0.10 if hovered else 0.04), true)
	draw_rect(area, Color(1, 1, 1, 0.9 if hovered else 0.35), false, 1.0)
	if debug:
		var font: Font = ThemeDB.fallback_font
		draw_string(font, Vector2(3, 12), str(data.get("label", "")),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
