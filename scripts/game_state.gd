extends Node
## Everything the story needs to remember. Autoload name: GameState.
##   GameState.set_flag("read_sign")       / GameState.has_flag("read_sign")
##   GameState.add_item("red_boot")        / GameState.has_item("red_boot")
##   GameState.new_loop()                  wipes the run, keeps loop count + endings
## F3 prints the whole state (debug builds only).

signal flag_changed(flag: String, value: Variant)
signal item_added(item_id: String)

var day: int = 1
var loop: int = 1
var current_room: String = ""
var flags: Dictionary = {}
var items: Array[String] = []
var endings_seen: Array[String] = []


func set_flag(flag: String, value: Variant = true) -> void:
	if flags.has(flag) and flags[flag] == value:
		return
	flags[flag] = value
	flag_changed.emit(flag, value)


func get_flag(flag: String, default_value: Variant = false) -> Variant:
	return flags.get(flag, default_value)


func has_flag(flag: String) -> bool:
	return bool(flags.get(flag, false))


func add_item(item_id: String) -> void:
	if items.has(item_id):
		return
	items.append(item_id)
	item_added.emit(item_id)


func has_item(item_id: String) -> bool:
	return items.has(item_id)


func enter_room(room_id: String) -> void:
	current_room = room_id
	set_flag("visited_" + room_id)


func record_ending(ending_id: String) -> void:
	if not endings_seen.has(ending_id):
		endings_seen.append(ending_id)


func new_loop() -> void:
	loop += 1
	day = 1
	current_room = ""
	flags.clear()
	items.clear()


func dump() -> void:
	print("--- GameState ---")
	print("loop=%d day=%d room=%s" % [loop, day, current_room])
	print("flags=", flags)
	print("items=", items)
	print("endings=", endings_seen)


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.keycode == KEY_F3 and OS.is_debug_build():
		dump()
