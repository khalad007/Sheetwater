class_name EndingData
extends RefCounted
## Ending cards as plain data. Keys:
##   lines     text lines that fade in one by one
##   title     large text shown after the lines
##   subtitle  small text under the title
##   sfx       optional sound played when the card appears
##   buttons   list of {text, do}; do = "loop" (new loop from the bus stop) or "quit"
## Triggered by a beat with "ending": "<id>" (see story_data.gd).

const ENDINGS: Dictionary = {
	"look": {
		"lines": [
			"Down the lane a man lowers his lantern. He has a face. He is crying, and you know his name.",
			"The village kept every mirror covered for a year, so that you would keep waking up.",
			"Nobody said her name, because you weren't ready to hear it. Today you were.",
		],
		"title": "SHEETWATER",
		"subtitle": "Ending 1 of 2: She Looked",
		"buttons": [
			{"text": "Play again", "do": "loop"},
			{"text": "Quit", "do": "quit"},
		],
	},
	"away": {
		"lines": [
			"The bus arrives at nine. You are its only passenger.",
			"The seat beside you is empty. It always has been.",
			"Under an inn bed, one more notebook is already waiting.",
		],
		"title": "DAY 1.",
		"subtitle": "Ending 2 of 2: She Looked Away",
		"buttons": [
			{"text": "Step off the bus", "do": "loop"},
		],
	},
}
