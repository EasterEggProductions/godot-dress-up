shader_type spatial;


uniform vec4 skin_tone : source_color = vec4(0.878431, 0.682353, 0.654902, 1.000000);
uniform sampler2D skin_shade : source_color, hint_default_transparent;

group_uniforms Eyes;
uniform vec2 eye_look = vec2(0.000000, 0.000000);
uniform sampler2D iris : source_color;
uniform sampler2D eyelashes : source_color, hint_default_transparent;
uniform sampler2D eye_mask : source_color;
uniform vec4 sclera_col : source_color = vec4(1,1,1,1);
uniform float interpupillary_distance = 0.1;
uniform float eye_height = 0.5;
uniform	float eye_scale = 3.0; 
uniform	float iris_scale = 1.0; 
uniform int blink_atlas_width = 2;
uniform float blink_left = 1;
uniform float blink_right = 1;

group_uniforms;

group_uniforms Eyebrows;
uniform sampler2D eyebrow : source_color, hint_default_transparent;
uniform float intereyebrow_distance = 0.1;
uniform float eyebrow_height = 0.8;
uniform float eyebrow_scale = 3.0;

group_uniforms;

group_uniforms Mouth;
uniform sampler2D mouth : source_color, hint_default_transparent;
uniform int mouth_atlas_width = 3;
uniform float mouth_height = 0.67;
uniform float mouth_offset = 0.5;
uniform float mouth_scale = 3.0;
uniform int mouth_state = 0;
group_uniforms;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 get_cropped_uv(vec2 aUV, vec2 center, float scale) {
	vec2 offset = center - vec2(0.5 / scale);
	return clamp((aUV - offset) * scale, vec2(0.0), vec2(1.0));
}

vec2 atlas_uv(vec2 local_uv, float openness) {
	int total_tiles = blink_atlas_width * blink_atlas_width;
	int idx = clamp(int(openness * float(total_tiles)), 0, total_tiles - 1);
	float tile_size = 1.0 / float(blink_atlas_width);
	float tile_x = float(idx % blink_atlas_width);
	float tile_y = float(idx / blink_atlas_width);
	return vec2(tile_x, tile_y) * tile_size + (local_uv * tile_size);
}

vec4 render_eye(vec2 aUV, float flip_mult) {
	float openness = flip_mult < 0.0 ? blink_left : blink_right;
	// mask UVs and scales
	float eye_mask_h_offset = eye_height - (1.0 / eye_scale * 0.5);
	float eye_mask_v_offset = (0.5 + (interpupillary_distance * flip_mult));
	vec2 mask_offset = vec2(eye_mask_v_offset, eye_mask_h_offset);	
	
	vec2 UV_scaled_mask = get_cropped_uv(aUV, vec2(eye_mask_v_offset, eye_height), eye_scale);
	//UV_scaled_mask.x = UV_scaled_mask.x * flip_mult;
	UV_scaled_mask.x = flip_mult < 0.0 ? 1.0 - UV_scaled_mask.x : UV_scaled_mask.x;
	vec4 i_mask = texture(eye_mask, atlas_uv(UV_scaled_mask, openness)); // the actual texture sample

	// iris UVs and scales
	float eye_iris_h_offset = eye_height - (1.0 / (eye_scale * iris_scale) * 0.5);
	float eye_iris_v_offset = (0.5 + (interpupillary_distance * flip_mult)); 
	vec2 iris_offset = vec2(eye_iris_v_offset, eye_iris_h_offset);	
	vec2 eye_iris_moved = aUV - iris_offset;
	
	//vec2 UV_scaled_iris = clamp(eye_iris_moved * (eye_scale * iris_scale) - eye_look, vec2(0,0), vec2(1.0,1.0));
	vec2 UV_scaled_iris = get_cropped_uv(aUV, vec2(eye_iris_v_offset, eye_height) - eye_look, (eye_scale * iris_scale));
	vec4 iris_m = texture(iris, UV_scaled_iris); // the actual texture sample
	//vec4 iris_m = texture(iris, clamp(UV_scaled_iris - eye_look, vec2(0,0), vec2(1.0,1.0))); // the actual texture sample



	vec4 working_col = ((i_mask.a)) + (sclera_col * (1.0 - i_mask.a));
	iris_m = iris_m * (1.0 - i_mask.a) + (sclera_col * (1.0 - iris_m.a));
	vec4 returnable = ((working_col * (i_mask.a)) + ((iris_m) * (1.0 - i_mask.a)));
	returnable.a = i_mask.a;
	return returnable; 
}

vec4 render_eyelid(vec2 aUV, float flip_mult) {
	float openness = flip_mult < 0.0 ? blink_left : blink_right;

	float h_offset = eye_height - (1.0 / eye_scale * 0.5);
	float v_offset = (0.5 + (interpupillary_distance * flip_mult));
	vec2 offset = vec2(v_offset, h_offset);

	vec2 uv_moved = aUV - offset;
	vec2 uv_scaled = get_cropped_uv(aUV, vec2(v_offset, eye_height), eye_scale);
	//uv_scaled.x *= flip_mult; 
	uv_scaled.x = flip_mult < 0.0 ? 1.0 - uv_scaled.x : uv_scaled.x;

	return texture(eyelashes, atlas_uv(uv_scaled, openness));
}

vec4 render_eyebrow(vec2 aUV, float flip_mult) {
	float h_offset = eyebrow_height - (0.5 / eyebrow_scale);
	float v_offset = (0.5 + (intereyebrow_distance * flip_mult)) - (0.5 / eyebrow_scale);
	vec2 offset = vec2(v_offset, h_offset);

	vec2 uv_moved = aUV - offset;
	vec2 uv_scaled = clamp(uv_moved * eyebrow_scale, vec2(0.0), vec2(1.0));
	uv_scaled.x *= flip_mult; 

	return texture(eyebrow, uv_scaled);
}

vec4 render_mouth(vec2 aUV) {
	vec2 uv = get_cropped_uv(aUV, vec2(mouth_offset, mouth_height), mouth_scale);
	// Atlas func pasted here 
	int total_tiles = mouth_atlas_width * mouth_atlas_width;
	int idx = clamp(mouth_state, 0, total_tiles - 1);
	float tile_size = 1.0 / float(mouth_atlas_width);
	float tile_x = float(idx % mouth_atlas_width);
	float tile_y = float(idx / mouth_atlas_width);
	//return vec2(tile_x, tile_y) * tile_size + (uv * tile_size);
	// end atlas func pasted here

	return texture(mouth, vec2(tile_x, tile_y) * tile_size + (uv * tile_size));
}

void fragment() {
	vec4 left_eye = render_eye(UV, -1.0);
	vec4 right_eye = render_eye(UV, 1.0);
	float whole_a = (1.0 - left_eye.a) + (1.0 - right_eye.a);
	right_eye *= 1.0 - right_eye.a;
	left_eye *= 1.0 - left_eye.a;

	vec4 left_brow = render_eyebrow(UV, -1.0);
	vec4 right_brow = render_eyebrow(UV, 1.0);

	vec4 flesh_shade = texture(skin_shade, UV);
	vec4 flesh_col = mix(skin_tone, flesh_shade, flesh_shade.a);

	vec4 mouth_col = render_mouth(UV);
	flesh_col = mix(flesh_col, mouth_col, mouth_col.a);

	vec3 final_col = mix(flesh_col.rgb, left_eye.rgb + right_eye.rgb, whole_a); 
	final_col = mix(final_col, left_brow.rgb, left_brow.a);
	final_col = mix(final_col, right_brow.rgb, right_brow.a);

	vec4 left_lash = render_eyelid(UV, 1);
	vec4 right_lash = render_eyelid(UV, -1);
	final_col = mix(final_col, left_lash.rgb, left_lash.a);
	final_col = mix(final_col, right_lash.rgb, right_lash.a);


	ALBEDO = final_col;
	// subtle brighten on the eye area only
	float eye_glow_mask = max(left_eye.a, right_eye.a); // or however you want to isolate sclera/iris
	//EMISSION = (left_eye.rgb + right_eye.rgb) * (1.0 - eye_glow_mask) * 0.15;
	
}
