extends Node
class_name DU_effect_bounce

@onready var mesh : MeshInstance3D = get_parent()
@onready var skele : Skeleton3D = mesh.get_parent()
@onready var material : Material = mesh.get_active_material(0)

@export var target_bone = "chest"
@export var img_dims : int = 8

# Spring tuning
@export var stiffness := 30.0
@export var damping := 6.0
@export var max_disp := 0.15

@export var gravity = -1.5

var spring_pos := Vector3.ZERO
var spring_vel := Vector3.ZERO

var vertex_offset_array : Image
var vertex_offset_image : ImageTexture

var vertex_home_positions : Array[Vector3]
var vertex_spring_pos : Array[Vector3]
var vertex_spring_vel : Array[Vector3]

@export var wind_noise : Texture2D
@export var noise_scroll_speed = 0.1
var noise_scroll_current = 0.0
@export var wind_strength = 1.0

func _ready() -> void:
	# Get vertex rest positions
	var verts = mesh.mesh.surface_get_arrays(0)[0] # vertex positions array
	vertex_home_positions = []
	vertex_spring_pos = []
	vertex_spring_vel = []
	for index in range(len(verts)):
		vertex_home_positions.append(verts[index])
		vertex_spring_pos.append(mesh.to_global(vertex_home_positions[index]))
		vertex_spring_vel.append(Vector3.ZERO)

	img_dims = int(sqrt(len(verts))) + 1

	# NOTE - Make material instance unique
	material = material.duplicate()
	mesh.material_override = material
	vertex_offset_array = Image.create(img_dims,img_dims, false, Image.FORMAT_RGBF) # TODO - not hard code size, determine at runtime
	vertex_offset_array.fill(Color.BLACK)
	vertex_offset_image = ImageTexture.create_from_image(vertex_offset_array)

	# make some noise!
	if wind_noise == null:
		var n_noise := NoiseTexture2D.new()
		n_noise.noise = FastNoiseLite.new()
		wind_noise = n_noise


	


func _process(delta: float) -> void:
	noise_scroll_current = fmod(noise_scroll_current + (delta*noise_scroll_speed), 1.0) 
	var bone_final_pose = skele.get_bone_global_pose(skele.find_bone(target_bone))
	
	for vind in range(len(vertex_home_positions)):
		var x = vind % img_dims
		var y = vind / img_dims

		# Calculate positions 
		var target = skele.to_global(bone_final_pose * vertex_home_positions[vind]) 
		var wind_target = wind_noise.get_image().get_pixel(((x * 512) + int(noise_scroll_current * 512)) % 512, ((y * 512) + int(noise_scroll_current * 512)) % 512) 
		
		var force = ((target - vertex_spring_pos[vind]) * stiffness) + Vector3(0,gravity,0) + Vector3(wind_target.r*wind_strength, wind_target.g*wind_strength, wind_target.b*wind_strength)
		force -= vertex_spring_vel[vind] * damping

		# Integrate velocity and position
		vertex_spring_vel[vind] += force * delta
		vertex_spring_pos[vind] += vertex_spring_vel[vind] * delta

		var offset = vertex_spring_pos[vind] - target
		# Clamp maximum displacement
		if offset.length() > max_disp:
			offset = offset.normalized() * max_disp
		vertex_offset_array.set_pixel(x,y, Color(offset.x,offset.y,offset.z))
	
	vertex_offset_image.update(vertex_offset_array)
	material.set_shader_parameter("vertext_offset_array", vertex_offset_image)
