extends CanvasLayer
## Full-screen black fader. Autoload name: Fade.
##   await Fade.to_black(0.5)
##   await Fade.from_black(0.5)
##   Fade.set_black()          instant black (used at startup)
## While fading, the black rect blocks mouse input. Don't start a second
## fade while one is running (main.gd guards this).

var _rect: ColorRect
var _tween: Tween


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func set_black() -> void:
	_rect.color.a = 1.0
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP


func to_black(duration: float = 0.5) -> void:
	await _fade(1.0, duration)


func from_black(duration: float = 0.5) -> void:
	await _fade(0.0, duration)


func _fade(alpha: float, duration: float) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	if duration <= 0.0:
		_rect.color.a = alpha
	else:
		_tween = create_tween()
		_tween.tween_property(_rect, "color:a", alpha, duration)
		await _tween.finished
	if alpha <= 0.0:
		_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
