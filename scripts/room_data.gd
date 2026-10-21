class_name RoomData
extends RefCounted
## All rooms as plain data. Keys per room:
##   title     placeholder label shown while there is no background art
##   color     placeholder background colour (hex string)
##   bg        path to a 640x360 PNG; used automatically once the file exists
##   hotspots  list of clickable areas. Each has:
##               id, label, rect [x, y, width, height] in 640x360 space
##               and EITHER "text" (shows a caption) OR "exit" (room id to go to)
## These three rooms are test placeholders. Real rooms replace them later.

const ROOMS: Dictionary = {
	"bus_stop": {
		"title": "Bus Stop",
		"color": "#1b2430",
		"bg": "res://art/bg_bus_stop.png",
		"hotspots": [
			{"id": "sign", "label": "Sign", "rect": [40, 110, 60, 130],
				"text": "The sign has no name on it."},
			{"id": "bench", "label": "Bench", "rect": [200, 220, 170, 60],
				"text": "An empty bench. The wood is still warm."},
			{"id": "road", "label": "Road to the inn", "rect": [540, 100, 90, 200],
				"exit": "inn_room"},
		],
	},
	"inn_room": {
		"title": "Inn Room",
		"color": "#2a2018",
		"bg": "res://art/bg_inn_room.png",
		"hotspots": [
			{"id": "wardrobe", "label": "Wardrobe", "rect": [60, 90, 110, 200],
				"text": "The wardrobe door sticks. Something rattles inside."},
			{"id": "window", "label": "Window", "rect": [260, 70, 120, 100],
				"text": "Frosted glass. Nothing but pale light."},
			{"id": "door", "label": "Door to the lane", "rect": [540, 110, 90, 190],
				"exit": "village_lane"},
			{"id": "back", "label": "Back to the bus stop", "rect": [20, 260, 120, 70],
				"exit": "bus_stop"},
		],
	},
	"village_lane": {
		"title": "Village Lane",
		"color": "#1d2b27",
		"bg": "res://art/bg_village_lane.png",
		"hotspots": [
			{"id": "villager", "label": "Villager", "rect": [280, 120, 70, 170],
				"text": "He turns toward you. There is nothing to see in his face."},
			{"id": "inn", "label": "Back to the inn", "rect": [20, 100, 90, 200],
				"exit": "inn_room"},
		],
	},
}
