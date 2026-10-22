class_name GirlData
extends RefCounted
## Which found item gives the girl which feature. Order = draw order.
## "art" is a transparent PNG on the same 48x96 canvas as girl_base.png,
## drawn at "offset" (0,0 if the canvas matches). If the file doesn't exist,
## a placeholder shape is drawn instead. "voice" has no picture on purpose.

const BASE_ART: String = "res://art/girl_base.png"
const VOICE_ITEM: String = "voice_tape"

const FEATURES: Array = [
	{"id": "feet", "item": "red_boot", "art": "res://art/girl_feet.png", "offset": [0, 0]},
	{"id": "coat", "item": "red_coat", "art": "res://art/girl_coat.png", "offset": [0, 0]},
	{"id": "hands", "item": "child_drawing", "art": "res://art/girl_hands.png", "offset": [0, 0]},
	{"id": "voice", "item": VOICE_ITEM, "art": ""},
]
