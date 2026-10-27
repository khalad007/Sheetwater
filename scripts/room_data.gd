class_name RoomData
extends RefCounted
## All rooms as plain data. Keys per room:
##   title     placeholder label shown while there is no background art
##   color     placeholder background colour (hex string)
##   bg        path to a 640x360 PNG; used automatically once the file exists
##   variants  optional list of {"if": [conditions], "room": id}: when this room is
##             entered, the first entry whose conditions pass is loaded instead
##             (RoomData.resolve). The variant room is a full room of its own.
##   bgs       optional list of {"if": [conditions], "bg": path}: the first entry whose
##             conditions pass replaces "bg", and the room swaps backgrounds in place
##             (with a quick blink) whenever a flag changes. Put the most specific first.
##   girl      optional {"pos": [x, y], "show_if": [conditions]}: the faceless girl,
##             top-left of her 48x96 box, in 640x360 space. Keep her at a frame edge.
##   fx        optional list of atmosphere layers drawn over the room (see RoomFx):
##               {"type": "fog", "alpha": 0.35, "speed": 0.08, "tint": "#aeb9c4", "scale": 3.0}
##               {"type": "rain", "amount": 120, "alpha": 0.3}
##               {"type": "flicker", "depth": 0.3}     brief dips into darkness
##             each may also carry "show_if": [conditions]
##   ambient   optional sound name looped under the room (res://audio/<name>.wav),
##             plus optional "ambient_db" (default -8). No "ambient" = silence.
##   on_enter  optional list of {"beat": id, "if": [conditions]}. After the room fades
##             in, the first entry whose conditions pass plays. The beat should set a
##             flag, otherwise it plays on every visit.
##   hotspots  list of clickable areas. Each has:
##       id, label, rect [x, y, width, height] in 640x360 space
##       and ONE of "text" (caption), "beat" (a StoryData beat) or "exit" (room id)
##     optional:
##       "needs":       [conditions]  all must be true or the click is refused
##       "locked_text": caption shown when refused (default "Not yet.")
##       "sets":        flag name set to true on a successful click
##       "sfx":         sound name played on a successful click (res://audio/<name>.wav)
##       "gives":       item id added on a successful click; the hotspot then disappears
##       "show_if":     [conditions]  hotspot only exists while all are true
##       "hide_if":     [conditions]  hotspot disappears when all are true
##       "sprite":      {"art": path, "tint": hex}  hotspot draws a person (see hotspot.gd)
##       "beat_again":  beat to play on later clicks, once "done_flag" is set
##       "text_if":     [{"if": [conditions], "text": "..."}]  first match replaces "text"
##       "beat_if":     [{"if": [conditions], "beat": id}]     first match replaces "beat"
##       "done_flag":   flag that marks the first conversation as finished
## Conditions: "flag:name", "item:name", "loop:N" (loop N or later), "ending:id" (seen in any run); prefix "!" to negate.
## Keep captions to about 150 characters; use a beat for anything longer.

const ROOMS: Dictionary = {
	"bus_stop": {
		"title": "Bus Stop",
		"color": "#1b2430",
		"bg": "res://art/bg_bus_stop.png",
		"girl": {"pos": [4, 200]},
		"fx": [
			{"type": "fog", "alpha": 0.35, "speed": 0.08},
			{"type": "rain", "amount": 110, "alpha": 0.28},
		],
		"ambient": "wind",
		"arrival": {
			"art": "res://art/bus.png",
			"if": ["!flag:arrived"],
			"from": [575, 252],
			"size": [130, 82],
			"steps": [
				{"wait": 1.5},
				{"to": [548, 236], "scale": 0.85, "time": 0.7, "ease": "in", "alpha": 0.0},
			],
		},
		"on_enter": [
			{"beat": "arrive_loop", "if": ["!flag:arrived", "loop:2"]},
			{"beat": "arrive", "if": ["!flag:arrived"]},
		],
		"hotspots": [
			{"id": "sign", "label": "Sign", "rect": [465, 165, 50, 112],
				"text": "The sign has no name on it.",
				"text_if": [{"if": ["loop:2"], "text": "No name on the sign. Scratched low on the post: rows of strokes, bundled in fives. Too many to count."}],
				"sets": "read_sign"},
			{"id": "timetable", "label": "Shelter wall", "rect": [340, 165, 105, 55],
				"text": "Scratched into the shelter's back wall: a bus timetable. One bus a day. Arrivals only.",
				"sets": "read_timetable"},
			{"id": "bench", "label": "Bench", "rect": [335, 222, 110, 75],
				"text": "Under the bench: a brass key on a paper tag. The tag has no number.",
				"text_if": [{"if": ["loop:2"], "text": "Under the bench: the brass key. The paper tag is soft with handling, the number rubbed away by a thumb."}],
				"gives": "room_key"},
			{"id": "road", "label": "Road to the inn", "rect": [520, 180, 120, 160],
				"exit": "inn_room"},
		],
	},
	"inn_room": {
		"title": "Inn Room",
		"color": "#2a2018",
		"bg": "res://art/bg_inn_room.png",
		"variants": [{"if": ["flag:played_tape"], "room": "inn_notebooks"}],
		"girl": {"pos": [4, 190]},
		"fx": [
			{"type": "flicker", "depth": 0.3},
		],
		"ambient": "drip",
		"hotspots": [
			{"id": "bed", "label": "Bed", "rect": [196, 188, 248, 105],
				"beat": "bed_1", "beat_if": [{"if": ["loop:2"], "beat": "bed2_1"}]},
			{"id": "wardrobe", "label": "Wardrobe", "rect": [21, 53, 147, 295],
				"needs": ["flag:looked_window"],
				"locked_text": "The door sticks. Something rattles inside. You need more light.",
				"text": "In a coat pocket: a child's drawing of a hand held inside a larger hand.",
				"gives": "child_drawing"},
			{"id": "window", "label": "Window", "rect": [284, 85, 76, 102],
				"text": "Frosted glass. Nothing but pale light.", "sets": "looked_window"},
			{"id": "door", "label": "Door to the lane", "rect": [538, 42, 78, 288],
				"needs": ["item:room_key"],
				"locked_text": "The door is locked.",
				"exit": "village_lane"},
			{"id": "back", "label": "Back to the bus stop", "rect": [215, 325, 210, 35],
				"exit": "bus_stop"},
		],
	},
	"village_lane": {
		"title": "Village Lane",
		"color": "#1d2b27",
		"bg": "res://art/bg_village_lane.png",
		"girl": {"pos": [588, 190]},
		"fx": [
			{"type": "fog", "alpha": 0.3, "speed": 0.06},
		],
		"ambient": "wind",
		"on_enter": [{"beat": "lane_arrive", "if": ["!flag:lane_seen"]}],
		"hotspots": [
			{"id": "car", "label": "Car", "rect": [305, 178, 175, 115],
				"text": "Both wing mirrors have been painted over, flat grey. The paint is still fresh.",
				"sets": "saw_car_mirrors"},
			{"id": "puddle", "label": "Puddle", "rect": [140, 336, 105, 24],
				"show_if": ["item:child_drawing"],
				"text": "The puddle is white with salt. It shows only sky."},
			{"id": "inn", "label": "Back to the inn", "rect": [155, 68, 100, 252],
				"exit": "inn_room"},
			{"id": "to_school", "label": "Path to the school", "rect": [505, 100, 60, 110],
				"show_if": ["flag:villager_route"],
				"needs": ["item:school_key"],
				"locked_text": "The schoolhouse will be locked. Someone in the lane may have a key.",
				"exit": "school"},
			{"id": "to_chapel", "label": "Path to the chapel", "rect": [440, 108, 60, 62],
				"show_if": ["flag:found_notebooks"],
				"exit": "chapel"},
			{"id": "old_man", "label": "Old man", "rect": [28, 212, 72, 136],
				"sprite": {"art": "res://art/villager_2.png", "tint": "#4a5560"},
				"beat": "villager_1", "done_flag": "talked_old_man", "beat_again": "villager_again"},
			{"id": "lantern_man", "label": "Man with a lantern", "rect": [262, 236, 56, 106],
				"sprite": {"art": "res://art/villager_4.png", "tint": "#3f4a40"},
				"beat": "lamp_1", "beat_if": [{"if": ["loop:2"], "beat": "lamp2_1"}],
				"done_flag": "talked_lantern", "beat_again": "lamp_again"},
			{"id": "elder", "label": "Old woman", "rect": [392, 250, 52, 98],
				"sprite": {"art": "res://art/villager_1.png", "tint": "#52484a"},
				"beat": "elder_1", "beat_if": [{"if": ["loop:2"], "beat": "elder2_1"}],
				"done_flag": "talked_elder", "beat_again": "elder_again"},
			{"id": "woman", "label": "Woman in an apron", "rect": [486, 214, 72, 136],
				"sprite": {"art": "res://art/villager_3.png", "tint": "#554b42"},
				"beat": "woman_1", "done_flag": "talked_woman", "beat_again": "woman_again"},
		],
	},
	"school": {
		"title": "School",
		"color": "#222a2e",
		"bg": "res://art/bg_school.png",
		"girl": {"pos": [4, 200]},
		"fx": [
			{"type": "fog", "alpha": 0.25, "speed": 0.05},
			{"type": "rain", "amount": 90, "alpha": 0.25},
		],
		"ambient": "wind",
		"hotspots": [
			{"id": "swing", "label": "Swing", "rect": [48, 130, 168, 132],
				"text": "The swings are moving a little, though there is no wind."},
			{"id": "bell", "label": "School bell", "rect": [325, 128, 42, 155],
				"sfx": "school_bell",
				"text": "You pull the rope. The bell rings once, a moment after your hand has let go."},
			{"id": "hooks", "label": "Coat hooks", "rect": [485, 160, 85, 45],
				"text": "A row of hooks at child height, name tags faded to blank. One hook is empty, its tag torn away.",
				"sets": "saw_hooks"},
			{"id": "boot", "label": "Red boot", "rect": [505, 275, 36, 30],
				"text": "Under the empty hook: a small red rain boot, still damp inside. Just one.",
				"gives": "red_boot"},
			{"id": "to_lake", "label": "Path to the lake", "rect": [215, 165, 105, 70],
				"needs": ["item:red_boot"],
				"locked_text": "There is something small in this schoolhouse I haven't found yet.",
				"exit": "lake_shore"},
			{"id": "back", "label": "Back to the lane", "rect": [215, 325, 210, 35],
				"exit": "village_lane"},
		],
	},
	"lake_shore": {
		"title": "Lake Shore",
		"color": "#26323a",
		"bg": "res://art/bg_lake_shore.png",
		"girl": {"pos": [560, 175]},
		"fx": [
			{"type": "fog", "alpha": 0.45, "speed": 0.04, "scale": 2.4},
		],
		"ambient": "lake_hush",
		"on_enter": [{"beat": "phone_buzz", "if": ["!flag:phone_buzzed"]}],
		"hotspots": [
			{"id": "water", "label": "The water", "rect": [10, 182, 330, 92],
				"text": "The lake is a flat pale sheet. Not the sky, not the reeds, not even the far shore shows in it.",
				"sets": "saw_water"},
			{"id": "recorder", "label": "Tape recorder", "rect": [343, 208, 48, 32],
				"beat": "tape_1", "gives": "voice_tape"},
			{"id": "coat", "label": "Red coat", "rect": [443, 200, 46, 36],
				"text": "A small red coat folded over the bench at the end of the jetty. One sleeve is stiff with dried lake water.",
				"gives": "red_coat"},
			{"id": "back", "label": "Back to the school", "rect": [215, 325, 210, 35],
				"exit": "school"},
		],
	},
	"inn_notebooks": {
		"title": "Inn Room",
		"color": "#241c16",
		"bg": "res://art/bg_inn_notebooks.png",
		"girl": {"pos": [4, 190]},
		"fx": [
			{"type": "flicker", "depth": 0.4},
		],
		"ambient": "drip",
		"on_enter": [
			{"beat": "nb_enter_loop", "if": ["!flag:nb_room_seen", "loop:2"]},
			{"beat": "nb_enter", "if": ["!flag:nb_room_seen"]},
		],
		"hotspots": [
			{"id": "window", "label": "Window", "rect": [285, 86, 71, 93],
				"text": "Frosted glass. Nothing but pale light.", "sets": "looked_window"},
			{"id": "wardrobe", "label": "Wardrobe", "rect": [25, 51, 145, 247],
				"needs": ["flag:looked_window"],
				"locked_text": "The door sticks. Something rattles inside. You need more light.",
				"text": "In a coat pocket: a child's drawing of a hand held inside a larger hand.",
				"gives": "child_drawing"},
			{"id": "door", "label": "Door to the lane", "rect": [534, 41, 70, 262],
				"needs": ["item:room_key"],
				"locked_text": "The door is locked.",
				"exit": "village_lane"},
			{"id": "bed", "label": "Bed", "rect": [198, 191, 244, 100],
				"text": "You can't bring yourself to lie down. Not with the floor like that."},
			{"id": "back", "label": "Back to the bus stop", "rect": [325, 310, 125, 45],
				"exit": "bus_stop"},
			{"id": "pile", "label": "Notebooks", "rect": [160, 72, 118, 114],
				"sfx": "paper_rustle",
				"beat": "pile_1", "beat_if": [{"if": ["ending:away"], "beat": "pile_away_1"}],
				"done_flag": "found_notebooks", "beat_again": "pile_again"},
		],
	},
	"chapel": {
		"title": "Chapel",
		"color": "#20242a",
		"bg": "res://art/bg_chapel.png",
		"girl": {"pos": [588, 190]},
		"fx": [
			{"type": "fog", "alpha": 0.15, "speed": 0.03},
		],
		"ambient": "chapel_hush",
		"on_enter": [{"beat": "chapel_enter", "if": ["!flag:chapel_seen"]}],
		"hotspots": [
			{"id": "window", "label": "High window", "rect": [388, 18, 46, 140],
				"text": "Clear glass, the first in the village. One long bar of light falls from it across the pews.",
				"sets": "saw_chapel_window"},
			{"id": "mirror", "label": "The covered mirror", "rect": [186, 124, 80, 122],
				"needs": ["item:red_boot", "item:red_coat", "item:child_drawing", "item:voice_tape"],
				"locked_text": "The sheet won't stir. Something of her is still missing: her feet, her coat, her hands, her voice.",
				"exit": "mirror"},
			{"id": "pews", "label": "Pews", "rect": [80, 250, 245, 70],
				"text": "Every bench is worn smooth in the same few places, as if the whole village sits here each morning, waiting."},
			{"id": "back", "label": "Back to the lane", "rect": [215, 325, 210, 35],
				"exit": "village_lane"},
		],
	},
	"mirror": {
		"title": "The Mirror",
		"color": "#14161a",
		"bg": "res://art/bg_mirror_covered.png",
		"bgs": [
			{"if": ["flag:reflection"], "bg": "res://art/bg_mirror_reveal.png"},
			{"if": ["flag:sheet_off"], "bg": "res://art/bg_mirror_bare.png"},
		],
		"ambient": "chapel_hush",
		"hotspots": [
			{"id": "sheet", "label": "The sheet", "rect": [228, 22, 177, 332],
				"hide_if": ["flag:sheet_off"],
				"beat": "mirror_1", "beat_if": [{"if": ["loop:2"], "beat": "mirror2_1"}],
				"done_flag": "mirror_seen", "beat_again": "mirror_again"},
			{"id": "back", "label": "Step back", "rect": [30, 336, 160, 24],
				"exit": "chapel"},
		],
	},
}


## Returns the room that should actually load for room_id (see "variants").
static func resolve(room_id: String) -> String:
	var data: Dictionary = ROOMS.get(room_id, {})
	for v: Dictionary in data.get("variants", []):
		if GameState.check_all(v.get("if", [])):
			return str(v["room"])
	return room_id
