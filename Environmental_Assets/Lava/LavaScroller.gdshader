shader_type spatial;
render_mode blend_mix;

uniform sampler2D lava_texture;
uniform float scroll_speed = 0.05;
uniform float emission_strength = 2.0;

void fragment() {
    vec2 uv = UV;
    uv.x += TIME * scroll_speed;

    vec4 tex = texture(lava_texture, uv);

    ALBEDO = tex.rgb;
    ALPHA = tex.a;

    EMISSION = tex.rgb * emission_strength;
}