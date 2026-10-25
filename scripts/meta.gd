extends Node
## Settings + progress that survive between launches. Autoload name: Meta

const SAVE_PATH: String = "user://sheetwater_settings.cfg"
const TOTAL_ENDINGS: int = 2

var master_volume: float = 1.0   # 0.0 .. 1.0
var fullscreen: bool = false
var endings_seen: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_data()
	apply_volume()
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func apply_volume() -> void:
	var bus: int = AudioServer.get_bus_index("Master")
	var db: float = -80.0
	if master_volume > 0.001:
		db = linear_to_db(master_volume)
	AudioServer.set_bus_volume_db(bus, db)


func set_fullscreen(on: bool) -> void:
	fullscreen = on
	if on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_data()


func mark_ending(id: String) -> void:
	if id.is_empty() or endings_seen.has(id):
		return
	endings_seen.append(id)
	save_data()


func save_data() -> void:
	var cfg := ConfigFile.new()
	var arr: Array = []
	arr.append_array(endings_seen)
	cfg.set_value("settings", "volume", master_volume)
	cfg.set_value("settings", "fullscreen", fullscreen)
	cfg.set_value("progress", "endings", arr)
	cfg.save(SAVE_PATH)


func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	master_volume = clampf(float(cfg.get_value("settings", "volume", 1.0)), 0.0, 1.0)
	fullscreen = bool(cfg.get_value("settings", "fullscreen", false))
	endings_seen.clear()
	for id in cfg.get_value("progress", "endings", []):
		endings_seen.append(str(id))


# Debug: F10 forgets which endings you've seen (to test the title screen).
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.keycode == KEY_F10 and OS.is_debug_build():
		endings_seen.clear()
		save_data()
		print("Meta: endings reset")
