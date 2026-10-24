class_name NotebookData
extends RefCounted
## All item descriptions and notebook notes as plain data.
## ITEMS: id -> {name, desc}. Every id used in a hotspot "gives" needs an entry here.
## NOTES: shown in order, each only once its "show_if" conditions are true
##        (same condition syntax as hotspots: "flag:x", "item:x", "!" to negate).
## Notes are Mara's own words. The very first line starts with "Day 1." on purpose.

const ITEMS: Dictionary = {
	"room_key": {
		"name": "Brass key",
		"desc": "A key on a paper tag. The tag has no number, only a smudge where one was rubbed out.",
	},
	"child_drawing": {
		"name": "Child's drawing",
		"desc": "A small hand held inside a larger hand. The crayon was pressed hard enough to tear the paper.",
	},
	"red_boot": {
		"name": "Red rain boot",
		"desc": "A child's boot, still damp inside. The left one. There is no right one.",
	},
	"red_coat": {
		"name": "Red coat",
		"desc": "Small, with a hood. One sleeve is stiff with dried lake water.",
	},
	"voice_tape": {
		"name": "Recording",
		"desc": "A tape of a child's voice. Static cuts out one word, every time you play it.",
	},
}

const NOTES: Array = [
	{"id": "n_arrived",
		"text": "Day 1. Arrived. The bus was empty except for me. No one waiting at the stop.",
		"show_if": ["flag:visited_bus_stop"]},
	{"id": "n_casefile",
		"text": "Case file: girl, 8, last seen by the water. No photo attached. No case number. Nobody is listed as having reported her missing.",
		"show_if": ["flag:arrived"]},
	{"id": "n_sign",
		"text": "The sign at the stop has no name on it. Ask someone what this place is called.",
		"show_if": ["flag:read_sign"]},
	{"id": "n_timetable",
		"text": "The bus timetable lists arrivals only. Nothing seems to leave.",
		"show_if": ["flag:read_timetable"]},
	{"id": "n_firstline",
		"text": "My own notebook already says 'No mirrors.' on the first line. I must have written it on the bus.",
		"show_if": ["flag:read_first_line"]},
	{"id": "n_windows",
		"text": "The glass is frosted. I haven't seen a clear window yet.",
		"show_if": ["flag:looked_window"]},
	{"id": "n_drawing",
		"text": "A child's drawing, in a coat in the wardrobe. A small hand inside a bigger one. I feel like I should know whose it is.",
		"show_if": ["item:child_drawing"]},
	{"id": "n_route",
		"text": "School first, then the lake, then the chapel. Everyone says 'she'. Nobody says her name.",
		"show_if": ["flag:villager_route"]},
	{"id": "n_car",
		"text": "The wing mirrors on the parked car are painted over. Someone did it recently.",
		"show_if": ["flag:saw_car_mirrors"]},
]
