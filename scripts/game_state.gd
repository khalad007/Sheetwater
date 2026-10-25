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
	
## Conditions are strings: "flag:name", "item:name", optionally prefixed "!".
## Conditions are strings: "flag:name", "item:name", "loop:N" (this is loop N or later),
## "ending:id" (that ending was seen in any run). Prefix "!" to negate.
func check(cond: String) -> bool:
	var negate: bool = cond.begins_with("!")
	var body: String = cond.substr(1) if negate else cond
	var result: bool
	if body.begins_with("flag:"):
		result = has_flag(body.substr(5))
	elif body.begins_with("item:"):
		result = has_item(body.substr(5))
	elif body.begins_with("loop:"):
		result = loop >= int(body.substr(5))
	elif body.begins_with("ending:"):
		result = endings_seen.has(body.substr(7))
	else:
		push_warning("GameState.check: bad condition '%s'" % cond)
		return false
	return result != negate


func check_all(conds: Array) -> bool:
	for c in conds:
		if not check(str(c)):
			return false
	return true


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
	if key == null or not key.pressed or key.echo or not OS.is_debug_build():
		return
	if key.keycode == KEY_F3:
		dump()
	elif key.keycode == KEY_F4:
		_debug_give_next_piece()


## Debug only (F4): give the next missing girl piece, so you can test her.
func _debug_give_next_piece() -> void:
	for f: Dictionary in GirlData.FEATURES:
		if not has_item(f["item"]):
			add_item(f["item"])
			print("DEBUG gave ", f["item"])
			return
	print("DEBUG: the girl already has every piece")
