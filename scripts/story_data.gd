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
		"sfx": "tape_voice",
		"next": "tape_3",
	},
	"tape_3": {
		"speaker": "Mara",
		"text": "Again. ...Again. The static eats the same word every time. I know that voice. Why do I know that voice?",
		"sets": "played_tape",
	},
		# ---------- inn revisit: the notebooks ----------
	"nb_enter": {
		"text": "The room is the same. The bed is the same. But the floor is wrong: something is packed tight under the bed and along the wall, hundreds of small things stacked on one another.",
		"sets": "nb_room_seen",
	},
	"pile_1": {
		"text": "You kneel. They are notebooks, small and black, identical to the one in your pocket. Hundreds of them, stacked under the bed and all the way to the wardrobe.",
		"next": "pile_2",
	},
	"pile_2": {
		"text": "You open the top one. Your own handwriting, small and cramped. 'Day 1. Arrived. No mirrors. Don't let me look.'",
		"next": "pile_3",
	},
	"pile_3": {
		"text": "Another, from deeper in the pile. 'Day 1. Arrived. No mirrors. Found a boot at the school.' The day is the same. It is always 'Day 1.'",
		"next": "pile_4",
	},
	"pile_4": {
		"text": "'Day 1. Found a boot, a coat. Went to the lake. I couldn't stay by the water. I came back here and wrote this down so I wouldn't forget.'",
		"next": "pile_5",
	},
	"pile_5": {
		"text": "One near the bottom is swollen, as if it had been wet. 'Day 1. I got as far as the chapel. There is a sheet over something.' The line stops there.",
		"next": "pile_6",
	},
	"pile_6": {
		"speaker": "Mara",
		"text": "Somebody is copying my handwriting. That's the only explanation. Somebody wants me frightened.",
		"next": "pile_7",
	},
	"pile_7": {
		"speaker": "Mara",
		"text": "I've never been in this room before today. I arrived this morning.",
		"sets": "found_notebooks",
	},
	"pile_again": {
		"speaker": "Mara",
		"text": "Hundreds of 'Day 1'. I put the notebook back where I found it. I'm not reading any more of these.",
	},
		# ---------- chapel ----------
	"chapel_enter": {
		"text": "The chapel door opens at a touch. The aisle has been swept, the candles trimmed, every pew dusted, as if the whole village rehearsed this room. At the far wall stands something tall under a white sheet.",
		"sets": "chapel_seen",
	},

	# ---------- the mirror ----------
	"mirror_1": {
		"text": "The sheet hangs from the top of the frame, the only white thing in the chapel. The light from the high window stops exactly at its hem.",
		"sets": "mirror_seen",
		"next": "mirror_2",
	},
	"mirror_2": {
		"speaker": "Mara",
		"text": "A boot. A coat. A drawing. A voice. It all fits in my hands. Everything in this village sent me to this one spot.",
		"next": "mirror_3",
	},
	"mirror_3": {
		"text": "Behind you, very close, someone small is breathing. When you hold still, she holds still.",
		"next": "mirror_choice",
	},
	"mirror_again": {
		"text": "The sheet hangs without moving. Behind you, the small footsteps wait.",
		"next": "mirror_choice",
	},
	"mirror_choice": {
		"text": "In your pocket the notebook has fallen open on its own. The first line, in your own handwriting: 'No mirrors. Don't let me look.'",
		"choices": [
			{"text": "Lift the sheet.", "next": "look_1"},
			{"text": "Turn away.", "next": "away_1"},
			{"text": "Not yet."},
		],
	},

	# ---------- ending: she looked ----------
	"look_1": {
		"text": "You take the hem in both hands. The cloth slides down and pools at your feet, soft as a breath. The glass is dusty and dark. It shows the empty chapel, and you are standing right in front of it.",
		"sfx": "cloth_pull",
		"sets": "sheet_off",
		"next": "look_2",
	},
	"look_2": {
		"text": "Then the glass clears, slowly, like breath fading off a window. A tired woman in a grey coat, short dark hair, eyes red from crying. You saw her once before, a year ago, and it was more than you could bear.",
		"sfx": "music_box",
		"sets": "reflection",
		"next": "look_3",
	},
	"look_3": {
		"text": "And at her shoulder, close enough to touch, a small girl in a red hooded coat. She has a face. She is smiling at you.",
		"next": "look_4",
	},
	"look_4": {
		"speaker": "Mara",
		"text": "Elise.",
		"next": "look_5",
	},
	"look_5": {
		"speaker": "Elise",
		"text": "Mama. You looked.",
		"sfx": "girl_last_words",
		"next": "look_6",
	},
	"look_6": {
		"speaker": "Elise",
		"text": "It was only forty seconds. You can stop counting now.",
		"next": "look_7",
	},
	"look_7": {
		"text": "You stay until the sun reaches the glass. When you finally turn, there is nobody behind you. The chapel door stands open, and far down the path the lake holds the whole sky.",
		"sets": "ending_look",
		"ending": "look",
	},

	# ---------- ending: she looked away ----------
	"away_1": {
		"text": "You turn your back on the sheet. It hangs there, patient as the whole village. Behind you, small footsteps come close, stop, and wait.",
		"next": "away_2",
	},
	"away_2": {
		"speaker": "Mara",
		"text": "I should check the notebook. I should write something down.",
		"next": "away_3",
	},
	"away_3": {
		"text": "In the lane, a bus idles. The driver never honks. He never has to.",
		"sets": "ending_away",
		"ending": "away",
	},
		# ---------- replay variants (loop 2 and later) ----------
	"arrive_loop": {
		"text": "The bus pulls away. The driver nodded as you stepped off, the way you nod to someone you see every day. The seat beside yours stayed empty the whole way.",
		"sfx": "bus",
		"sets": "arrived",
		"next": "arrive_loop_2",
	},
	"arrive_loop_2": {
		"speaker": "Mara",
		"text": "Odd. I feel like I've stood on this exact spot before. Long bus rides do that.",
		"next": "arrive_2",
	},
	"bed2_1": {
		"text": "The bed is made. The pillow still holds a long dent, as if someone just got up.",
		"next": "bed2_2",
	},
	"bed2_2": {
		"text": "Your notebook lies open on the blanket. 'No mirrors.' The cover is crowded with tiny pencil strokes in rows of five, edge to edge.",
		"sets": "saw_tally_cover",
		"next": "bed2_3",
	},
	"bed2_3": {
		"speaker": "Mara",
		"text": "I don't remember doing that. Must have been the bus. There's nothing else to do on a bus that long.",
		"sets": "read_first_line",
	},
	"lamp2_1": {
		"text": "A thin man in work overalls holds a lantern, though it's broad daylight. The flame burns low and steady. He is already holding out a key.",
		"next": "lamp2_2",
	},
	"lamp2_2": {
		"speaker": "Man with the lantern",
		"text": "Schoolhouse key. You know the door. Lift as you turn it.",
		"gives": "school_key",
		"sets": "lamp_slip",
		"next": "lamp2_3",
	},
	"lamp2_3": {
		"speaker": "Mara",
		"text": "I've never been inside that school.",
		"next": "lamp2_4",
	},
	"lamp2_4": {
		"speaker": "Man with the lantern",
		"text": "No. Of course not. Everyone goes there first.",
		"sets": "talked_lantern",
	},
	"elder2_1": {
		"text": "An old woman leans on a cane at the corner. She is the only one who holds still while you look at her.",
		"next": "elder2_2",
	},
	"elder2_2": {
		"speaker": "Old woman",
		"text": "Cold hands. Kind, but cold. They were warmer when she was little.",
		"sets": "elder_slip",
		"next": "elder2_3",
	},
	"elder2_3": {
		"speaker": "Mara",
		"text": "When who was little? ...And I still don't remember wearing a ring. There's a pale band on my finger.",
		"next": "elder2_4",
	},
	"elder2_4": {
		"speaker": "Old woman",
		"text": "Nobody, dear. Old women ramble. Some things you keep in a pocket instead.",
		"sets": "talked_elder",
	},
	"nb_enter_loop": {
		"text": "The room is the same. The floor is wrong again: notebooks packed under the bed and along the wall. The stacks reach a little higher up the wardrobe than they should, and you can't say how you know that.",
		"sets": "nb_room_seen",
	},
	"pile_away_1": {
		"text": "You kneel. The same small black notebooks, the same leaning stacks. The top one is warm, as if it was set down a moment ago.",
		"next": "pile_away_2",
	},
	"pile_away_2": {
		"text": "'Day 1. Arrived. No mirrors. Found a boot, a coat, a drawing, a voice. Went to the chapel. I turned my back on the sheet. I couldn't make myself look.'",
		"next": "pile_away_3",
	},
	"pile_away_3": {
		"text": "The handwriting is yours. The last line is yours. You have no memory of writing it.",
		"next": "pile_away_4",
	},
	"pile_away_4": {
		"speaker": "Mara",
		"text": "Somebody is copying my... Somebody is... No. I should go to the chapel.",
		"sets": "found_notebooks",
	},
	"mirror2_1": {
		"text": "The sheet hangs from the top of the frame, creased deep along the hem, as if it has been lifted and let fall a great many times. The light from the high window stops exactly at the cloth.",
		"sets": "mirror_seen",
		"next": "mirror_2",
	},
}
