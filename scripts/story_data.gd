class_name StoryData
extends RefCounted
## All spoken beats as plain data. See dialogue.gd for the keys.
## Rule for villagers (from the locked story): they never say "Elise", only "she".
## Mara's slips and the villagers' small certainties are the clues. Keep them quiet.

const BEATS: Dictionary = {
	# ---------- bus stop ----------
	"arrive": {
		"text": "The bus pulls away. You were its only passenger, and the seat beside yours stayed empty the whole way.",
		"sfx": "bus",
		"sets": "arrived",
		"next": "arrive_2",
	},
	"arrive_2": {
		"speaker": "Mara",
		"text": "Eight years old. Last seen by the water. No photo in the file. Someone here must know her.",
	},

	# ---------- inn room ----------
	"bed_1": {
		"text": "The bed is made. The pillow still holds a long dent, as if someone just got up.",
		"next": "bed_2",
	},
	"bed_2": {
		"text": "Your notebook lies open on the blanket. The first line, in your handwriting: 'No mirrors.'",
		"next": "bed_3",
	},
	"bed_3": {
		"speaker": "Mara",
		"text": "I don't remember writing that. Must have been on the bus.",
		"sets": "read_first_line",
	},

	# ---------- village lane ----------
	"lane_arrive": {
		"text": "The lane is full of people, and every one of them has turned to face you. You can't keep any of their faces.",
		"sets": "lane_seen",
	},

	# old man in the flat cap: the route
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
		"sets": "villager_route",
		"choices": [
			{"text": "Who's been waiting?", "next": "villager_who"},
			{"text": "Thank you.", "next": "villager_bye"},
		],
	},
	"villager_who": {
		"speaker": "Villager",
		"text": "You'll want to start with the school. The man with the lantern keeps the key.",
		"sets": "talked_old_man",
	},
	"villager_bye": {
		"speaker": "Villager",
		"text": "Mind the lake path. It's slippery in the mornings.",
		"sets": "talked_old_man",
	},
	"villager_again": {
		"speaker": "Villager",
		"text": "School first. Then the lake. Then the chapel. She is patient.",
	},

	# woman in the apron: "kept ready"
	"woman_1": {
		"text": "A woman in an apron stands at her doorstep, her headscarf tied tight. Her face is a pale smoothness. You can't hold its shape, even while you look.",
		"next": "woman_2",
	},
	"woman_2": {
		"speaker": "Woman",
		"text": "You look tired. Did you sleep?",
		"next": "woman_3",
	},
	"woman_3": {
		"speaker": "Mara",
		"text": "I think so. It's hard to say. I only arrived this morning.",
		"next": "woman_4",
	},
	"woman_4": {
		"speaker": "Woman",
		"text": "Of course. Your room is kept ready. It always is.",
		"choices": [
			{"text": "Always?", "next": "woman_always"},
			{"text": "Thank you.", "next": "woman_bye"},
		],
	},
	"woman_always": {
		"speaker": "Woman",
		"text": "For guests. We keep everything ready for guests.",
		"sets": "talked_woman",
	},
	"woman_bye": {
		"speaker": "Woman",
		"text": "Eat something before the lake. People forget.",
		"sets": "talked_woman",
	},
	"woman_again": {
		"speaker": "Woman",
		"text": "Eat something. People forget.",
	},

	# man with the lantern: the school key
	"lamp_1": {
		"text": "A thin man in work overalls holds a lantern, though it's broad daylight. The flame burns low and steady. He doesn't seem to notice it.",
		"next": "lamp_2",
	},
	"lamp_2": {
		"speaker": "Man with the lantern",
		"text": "Schoolhouse key. The door sticks, so lift as you turn it.",
		"gives": "school_key",
		"next": "lamp_3",
	},
	"lamp_3": {
		"speaker": "Mara",
		"text": "How did you know that's where I was going?",
		"next": "lamp_4",
	},
	"lamp_4": {
		"speaker": "Man with the lantern",
		"text": "Everyone goes there first.",
		"sets": "talked_lantern",
	},
	"lamp_again": {
		"speaker": "Man with the lantern",
		"text": "Lift as you turn it.",
	},

	# old woman with the cane: the ring
	"elder_1": {
		"text": "An old woman leans on a cane at the corner. She is the only one who holds still while you look at her. She, too, has no face you can keep.",
		"next": "elder_2",
	},
	"elder_2": {
		"speaker": "Old woman",
		"text": "You have cold hands. Kind, but cold.",
		"next": "elder_3",
	},
	"elder_3": {
		"speaker": "Mara",
		"text": "There's a pale band on my finger, as if a ring was taken off. I don't remember wearing one.",
		"next": "elder_4",
	},
	"elder_4": {
		"speaker": "Old woman",
		"text": "Some things you keep in a pocket instead, dear. They weigh less there.",
		"sets": "talked_elder",
	},
	"elder_again": {
		"speaker": "Old woman",
		"text": "Cold hands. Kind hands.",
	},
		# ---------- lake shore ----------
	"phone_buzz": {
		"text": "Your phone buzzes once against your hip. The screen is dark: no signal, no caller. It hasn't had a signal since the bus.",
		"sfx": "phone_buzz",
		"sets": "phone_buzzed",
	},
	"tape_1": {
		"text": "At the end of the jetty sits a small cassette recorder, its case beaded with water. A tape is already inside. Your thumb finds PLAY before you decide to press it.",
		"sfx": "tape_click",
		"next": "tape_2",
	},
	"tape_2": {
		"text": "A child's voice, thin through the static: 'Are you still on the phone? I'm going down to look at the water. I won't go in. I'll be right back, [static].'",
		"next": "tape_3",
	},
	"tape_3": {
		"speaker": "Mara",
		"text": "Again. ...Again. The static eats the same word every time. I know that voice. Why do I know that voice?",
		"sets": "played_tape",
	},
}
