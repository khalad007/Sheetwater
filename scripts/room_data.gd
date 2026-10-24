class_name RoomData
extends RefCounted
## All rooms as plain data. Keys per room:
##   title     placeholder label shown while there is no background art
##   color     placeholder background colour (hex string)
##   bg        path to a 640x360 PNG; used automatically once the file exists
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
##       "gives":       item id added on a successful click; the hotspot then disappears
##       "show_if":     [conditions]  hotspot only exists while all are true
##       "hide_if":     [conditions]  hotspot disappears when all are true
##       "sprite":      {"art": path, "tint": hex}  hotspot draws a person (see hotspot.gd)
##       "beat_again":  beat to play on later clicks, once "done_flag" is set
##       "done_flag":   flag that marks the first conversation as finished
## Conditions: "flag:name", "item:name", prefix "!" to negate.
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
		"on_enter": [{"beat": "arrive", "if": ["!flag:arrived"]}],
		"hotspots": [
			{"id": "sign", "label": "Sign", "rect": [465, 165, 50, 112],
				"text": "The sign has no name on it.", "sets": "read_sign"},
			{"id": "timetable", "label": "Shelter wall", "rect": [340, 165, 105, 55],
				"text": "Scratched into the shelter's back wall: a bus timetable. One bus a day. Arrivals only.",
				"sets": "read_timetable"},
			{"id": "bench", "label": "Bench", "rect": [335, 222, 110, 75],
				"text": "Under the bench: a brass key on a paper tag. The tag has no number.",
				"gives": "room_key"},
			{"id": "road", "label": "Road to the inn", "rect": [520, 180, 120, 160],
				"exit": "inn_room"},
		],
	},
	"inn_room": {
		"title": "Inn Room",
		"color": "#2a2018",
		"bg": "res://art/bg_inn_room.png",
		"girl": {"pos": [4, 190]},
		"fx": [
			{"type": "flicker", "depth": 0.3},
		],
		"ambient": "drip",
		"hotspots": [
			{"id": "bed", "label": "Bed", "rect": [196, 188, 248, 105],
				"beat": "bed_1"},
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
			{"id": "old_man", "label": "Old man", "rect": [28, 212, 72, 136],
				"sprite": {"art": "res://art/villager_2.png", "tint": "#4a5560"},
				"beat": "villager_1", "done_flag": "talked_old_man", "beat_again": "villager_again"},
			{"id": "lantern_man", "label": "Man with a lantern", "rect": [262, 236, 56, 106],
				"sprite": {"art": "res://art/villager_4.png", "tint": "#3f4a40"},
				"beat": "lamp_1", "done_flag": "talked_lantern", "beat_again": "lamp_again"},
			{"id": "elder", "label": "Old woman", "rect": [392, 250, 52, 98],
				"sprite": {"art": "res://art/villager_1.png", "tint": "#52484a"},
				"beat": "elder_1", "done_flag": "talked_elder", "beat_again": "elder_again"},
			{"id": "woman", "label": "Woman in an apron", "rect": [486, 214, 72, 136],
				"sprite": {"art": "res://art/villager_3.png", "tint": "#554b42"},
				"beat": "woman_1", "done_flag": "talked_woman", "beat_again": "woman_again"},
		],
	},
	"school": {
		"title": "School",
		"color": "#222a2e",
		"bg": "res://art/bg_school.png",
		"ambient": "wind",
		"hotspots": [
			{"id": "back", "label": "Back to the lane", "rect": [215, 325, 210, 35],
				"exit": "village_lane"},
		],
	},
}
