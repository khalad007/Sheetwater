class_name RoomFx
extends RefCounted
## Builds a room's atmosphere layers from its "fx" list (see room_data.gd).
## Layers are added in list order, above the background and the girl but below
## hotspots and UI. None of them take mouse input.

static func build(parent: Control, fx_list: Array) -> void:
	for cfg: Dictionary in fx_list:
		if not GameState.check_all(cfg.get("show_if", [])):
			continue
		match str(cfg.get("type", "")):
			"fog":
				var fog := FogLayer.new()
				fog.config = cfg
				parent.add_child(fog)
			"rain":
				parent.add_child(_make_rain(cfg))
			"flicker":
				var flicker := FlickerLayer.new()
				flicker.depth = float(cfg.get("depth", 0.3))
				parent.add_child(flicker)
			_:
				push_warning("RoomFx: unknown fx type '%s'" % cfg.get("type", ""))


static func _make_rain(cfg: Dictionary) -> CPUParticles2D:
	var img := Image.create_empty(1, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var p := CPUParticles2D.new()
	p.texture = ImageTexture.create_from_image(img)
	p.amount = int(cfg.get("amount", 120))
	p.lifetime = 1.0
	p.preprocess = 1.0   # already falling when the room appears
	p.position = Vector2(320, -12)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(340, 1)
	p.direction = Vector2(0.12, 1.0)
	p.spread = 2.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 380.0
	p.initial_velocity_max = 460.0
	p.color = Color(0.72, 0.8, 0.92, float(cfg.get("alpha", 0.3)))
	return p
