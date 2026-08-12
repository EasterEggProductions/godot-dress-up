shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_disabled, diffuse_lambert, specular_schlick_ggx;

uniform float offset_array_square_dimension = 8.0;
uniform sampler2D vertext_offset_array : hint_default_black, filter_nearest;
uniform float displacement_strength : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D albedo;

void vertex() {
// FloatOp:35
	float n_out35p0 = mod(float(VERTEX_ID), offset_array_square_dimension);
	float nUV_x = n_out35p0 / offset_array_square_dimension;
	float total_pixel_count = offset_array_square_dimension * offset_array_square_dimension;
	float nUV_y = float(VERTEX_ID) / total_pixel_count;
	vec4 offset_somespace = texture(vertext_offset_array, vec2(nUV_x, nUV_y));
	vec3 offset_modelspace = (vec4(vec3(offset_somespace.xyz), 1.0) * MODEL_MATRIX).xyz;
	// COLOR.x is vertex data for weight of displacement, here add it with shader weight
	float dis_magnitude = COLOR.x * displacement_strength;
	// Displace vertex start position back into VERTEX
	VERTEX = fma(offset_modelspace, vec3(dis_magnitude), VERTEX); // fused multiply add
}

void fragment() {
	vec3 sRGB_col = vec3(texture(albedo, UV).xyz);
	// sRGB to linear conversion
	vec3 linear_col = mix(pow((sRGB_col.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), sRGB_col.rgb * (1.0 / 12.92), lessThan(sRGB_col.rgb, vec3(0.04045)));

	ALBEDO = linear_col;
	METALLIC = 0.66;
	ROUGHNESS = 0.75;
	SPECULAR = 0.5;
}
