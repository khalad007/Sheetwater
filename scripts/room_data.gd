class_name RoomData
extends RefCounted
## All rooms as plain data. Keys per room:
##   title     placeholder label shown while there is no background art
##   color     placeholder background colour (hex string)
##   bg        path to a 640x360 PNG; used automatically once the file exists
##   hotspots  list of clickable areas. Each has:
##   girl      optional {"pos": [x, y], "show_if": [conditions]}: the faceless girl,
##             top-left of her 48x96 box, in 640x360 space. Keep her at a frame edge.
##       id, label, rect [x, y, width, height] in 640x360 space
##       and EITHER "text" (caption) OR "exit" (room id to go to)
##     optional:
##       "needs":       [conditions]  all must be true or the click is refused
##       "locked_text": caption shown when refused (default "Not yet.")
##       "sets":        flag name set to true on a successful click
##       "gives":       item id added on a successful click; the hotspot then disappears
##       "beat":        id of a StoryData beat to play (use instead of "text")
##       "show_if":     [conditions]  hotspot only exists while all are true
##       "hide_if":     [conditions]  hotspot disappears when all are true
## Conditions: "flag:name", "item:name", prefix "!" to negate.
## These three rooms are a test chain. Real rooms replace them later.

const ROOMS: Dictionary = {
	"bus_stop": {
		"title": "Bus Stop",
		"color": "#1b2430",
		"bg": "res://art/bg_bus_stop.png",
		"girl": {"pos": [4, 200]},      # in "bus_stop"
		"hotspots": [
			{"id": "sign", "label": "Sign", "rect": [40, 110, 60, 130],
				"text": "The sign has no name on it.", "sets": "read_sign"},
			{"id": "bench", "label": "Bench", "rect": [200, 220, 170, 60],
				"text": "Under the bench: a brass key on a paper tag. The tag has no number.",
				"gives": "room_key"},
			{"id": "road", "label": "Road to the inn", "rect": [540, 100, 90, 200],
				"exit": "inn_room"},
		],
	},
	"inn_room": {
		"title": "Inn Room",
		"color": "#2a2018",
		"bg": "res://art/bg_inn_room.png",
		"girl": {"pos": [4, 190]},      # in "inn_room"
		"hotspots": [
			{"id": "wardrobe", "label": "Wardrobe", "rect": [60, 90, 110, 200],
				"needs": ["flag:looked_window"],
				"locked_text": "Too dark inside to see. The window might help.",
				"text": "In a coat pocket: a child's drawing of a hand held inside a larger hand.",
				"gives": "child_drawing"},
			{"id": "window", "label": "Window", "rect": [260, 70, 120, 100],
				"text": "Frosted glass. Nothing but pale light.", "sets": "looked_window"},
			{"id": "door", "label": "Door to the lane", "rect": [540, 110, 90, 190],
				"needs": ["item:room_key"],
				"locked_text": "The door is locked.",
				"exit": "village_lane"},
			{"id": "back", "label": "Back to the bus stop", "rect": [20, 260, 120, 70],
				"exit": "bus_stop"},
		],
	},
	"village_lane": {
		"title": "Village Lane",
		"color": "#1d2b27",
		"bg": "res://art/bg_village_lane.png",
		"girl": {"pos": [588, 190]},    # in "village_lane"
		"hotspots": [
			{"id": "villager", "label": "Villager", "rect": [280, 120, 70, 170],
				"beat": "villager_1"},
			{"id": "puddle", "label": "Puddle", "rect": [400, 270, 120, 40],
				"show_if": ["item:child_drawing"],
				"text": "The puddle is white with salt. It shows only sky."},
			{"id": "inn", "label": "Back to the inn", "rect": [20, 100, 90, 200],
				"exit": "inn_room"},
		],
	},
}
