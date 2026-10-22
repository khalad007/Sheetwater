class_name StoryData
extends RefCounted
## All spoken beats as plain data. See dialogue.gd for the keys.
## Rule for villagers (from the locked story): they never say "Elise", only "she".

const BEATS: Dictionary = {
	"villager_1": {
		"text": "He turns toward you. Where his face should be, your eye slides off, like a thumbprint on glass.",
		"next": "villager_2",
	},
	"villager_2": {
		"speaker": "Mara",
		"text": "Excuse me. I'm looking for a little girl. Eight years old. Her name is Elise.",
		"next": "villager_3",
	},
	"villager_3": {
		"speaker": "Villager",
		"text": "She's been waiting. School first. Then the lake. Then the chapel.",
		"choices": [
			{"text": "Who's waiting?", "next": "villager_who"},
			{"text": "Thank you.", "sets": "villager_route"},
		],
	},
	"villager_who": {
		"speaker": "Villager",
		"text": "You'll want to start with the school.",
		"sets": "villager_route",
	},
}
