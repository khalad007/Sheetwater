class_name FlickerLayer
extends ColorRect
## Dips the room into darkness in short stuttering bursts, built from
## fx {"type": "flicker", "depth": 0.3}. depth = how dark the dips get (0..1).

var depth: float = 0.3
var min_gap: float = 2.5
var max_gap: float = 7.0

var _timer: Timer


func _ready() -> void:
	color = Color(0, 0, 0, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_burst)
	add_child(_timer)
	_timer.start(randf_range(min_gap, max_gap))


func _burst() -> void:
	var tween := create_tween()
	for i in randi_range(2, 5):
		tween.tween_property(self, "color:a", depth * randf_range(0.5, 1.0), 0.04)
		tween.tween_property(self, "color:a", 0.0, randf_range(0.04, 0.12))
	tween.tween_callback(func(): _timer.start(randf_range(min_gap, max_gap)))
