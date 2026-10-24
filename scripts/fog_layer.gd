class_name FogLayer
extends ColorRect
## Slow drifting fog, built from fx {"type": "fog"}. Config keys:
##   alpha (0.35)   how thick the fog is
##   speed (0.08)   drift in noise cells per second (higher = faster)
##   tint ("#aeb9c4")   fog colour
##   scale (3.0)    bigger = smaller, busier clouds
## The fog is quantised to 4x4 pixel blocks to match the pixel art.

const SHADER_CODE: String = """
shader_type canvas_item;

uniform vec4 fog_color : source_color = vec4(0.68, 0.73, 0.77, 1.0);
uniform float fog_alpha = 0.35;
uniform float drift = 0.08;
uniform float tiles = 3.0;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * vnoise(p);
		p = p * 2.0 + vec2(17.0, 9.0);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 px = floor(UV * vec2(160.0, 90.0)) / vec2(160.0, 90.0);
	vec2 move = vec2(TIME * drift, TIME * drift * 0.25);
	float n = fbm(px * vec2(tiles * 1.78, tiles) + move);
	n = smoothstep(0.35, 0.85, n);
	float low = mix(0.5, 1.0, UV.y);
	COLOR = vec4(fog_color.rgb, n * fog_alpha * low);
}
"""

var config: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shader := Shader.new()
	shader.code = SHADER_CODE
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("fog_color", Color(str(config.get("tint", "#aeb9c4"))))
	mat.set_shader_parameter("fog_alpha", float(config.get("alpha", 0.35)))
	mat.set_shader_parameter("drift", float(config.get("speed", 0.08)))
	mat.set_shader_parameter("tiles", float(config.get("scale", 3.0)))
	material = mat
