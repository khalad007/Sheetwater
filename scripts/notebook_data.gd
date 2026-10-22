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
}

const NOTES: Array = [
	{"id": "n_arrived",
		"text": "Day 1. Arrived. The bus was empty except for me. No one waiting at the stop.",
		"show_if": ["flag:visited_bus_stop"]},
	{"id": "n_sign",
		"text": "The sign at the stop has no name on it. Ask someone what this place is called.",
		"show_if": ["flag:read_sign"]},
	{"id": "n_windows",
		"text": "The glass is frosted. I haven't seen a clear window yet.",
		"show_if": ["flag:looked_window"]},
	{"id": "n_drawing",
		"text": "A child's drawing, in a coat in the wardrobe. A small hand inside a bigger one. I feel like I should know whose it is.",
		"show_if": ["item:child_drawing"]},
]
