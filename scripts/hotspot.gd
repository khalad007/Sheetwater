class_name Hotspot
extends Control
## A clickable rectangle. All behaviour lives in `data` (see room_data.gd).
## refresh() re-evaluates visibility and lock state from GameState.
## If data has "sprite": {"art": path, "tint": hex}, the hotspot draws that sprite,
## fitted to the bottom-centre of its rect, with a tiny idle bob. No art file =
## a blank-faced silhouette placeholder.

signal activated(data: Dictionary)
signal hover_changed(spot: Hotspot, is_hovered: bool)

var data: Dictionary = {}
var hovered: bool = false
var unlocked: bool = true
var debug: bool = false:
	set(value):
		debug = value
		queue_redraw()

var _has_sprite: bool = false
var _sprite_tex: Texture2D
var _tint: Color = Color("#3d4650")
var _phase: float = 0.0
var _t: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	if data.has("sprite"):
		_has_sprite = true
		var cfg: Dictionary = data["sprite"]
		var path: String = cfg.get("art", "")
		if path != "" and ResourceLoader.exists(path):
			_sprite_tex = load(path) as Texture2D
		_tint = Color(str(cfg.get("tint", "#3d4650")))
		_phase = randf() * TAU
	set_process(_has_sprite)


func _process(delta: float) -> void:
	if is_visible_in_tree():
		_t += delta
		queue_redraw()


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
	if _has_sprite:
		_draw_sprite()
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


func _draw_sprite() -> void:
	var bob: float = sin(_t * 1.4 + _phase) * 0.8
	var lift: Color = Color(1.18, 1.18, 1.18) if hovered else Color.WHITE
	if _sprite_tex:
		var ts: Vector2 = _sprite_tex.get_size()
		var k: float = minf(size.x / ts.x, size.y / ts.y)
		var drawn: Vector2 = ts * k
		var pos := Vector2((size.x - drawn.x) / 2.0, size.y - drawn.y + bob)
		draw_texture_rect(_sprite_tex, Rect2(pos, drawn), false, lift)
	else:
		var col: Color = _tint * lift
		draw_circle(Vector2(size.x / 2.0, size.y * 0.14 + bob), size.x * 0.2, col.lightened(0.15))
		draw_rect(Rect2(size.x * 0.22, size.y * 0.28 + bob, size.x * 0.56, size.y * 0.72), col)
