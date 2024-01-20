// source: http://halisavakis.com/my-take-on-shaders-spherical-mask-dissolve/

shader_type spatial;
render_mode cull_disabled, world_vertex_coords;

uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec4 albedo_ring_color : source_color = vec4(1.0);
uniform float specular : hint_range(0, 1) = 0.5;
uniform float metallic : hint_range(0, 1) = 0;
// uniform float noise_size = 100;
// A positive ring size or zero cuts off the geometry, negative means apply color to all geometry outside the circle
uniform float ring_size = 0.03;
uniform vec3 sphere_mask_pos = vec3(0.0);
uniform float sphere_mask_radius = 2.0;
uniform float sphere_mask_softness = 1.0;

varying vec3 world_pos;

// float random(vec2 input) { 
// 	return fract(sin(dot(input, vec2(12.9898,78.233))) * 43758.5453123);
// }

void vertex() {
	world_pos = VERTEX;
}
void fragment() {
	float dist = distance(sphere_mask_pos, world_pos);
	float sphere_cutoff = (1.0 - clamp((dist - sphere_mask_radius) / sphere_mask_softness, 0.0, 1.0)) - 0.1;
	vec4 color = texture(albedo_texture, UV) * albedo_color;
	if (sphere_cutoff < 0.0) {
		if (ring_size < 0.0) {
			color = color * albedo_ring_color;
		} else {
			discard;
		}
	}
	// float squares = step(0.5, random(floor(UV * noise_size)));
	float ring_cutoff = step(sphere_cutoff, ring_size);
	if (ring_size > 0.0 && ring_cutoff > 0.0) {
		color = color * albedo_ring_color;
	}
	
	ALBEDO = color.rgb;
	SPECULAR = specular;
	METALLIC = metallic;
	// ALPHA = color.a;
}