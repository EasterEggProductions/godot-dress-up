extends Resource
class_name Garment

# SECTION Visuals of garment
@export var mesh : Mesh
@export var skin : Skin
@export var materials : Array[Material]
# SECTION OTHER DATA
@export var tags : Array[String]
@export var bones : Array[String]
@export var material_override_properties : Dictionary[StringName, Variant]

func spawn_garment() -> MeshInstance3D:
	var garment = MeshInstance3D.new()
	garment.mesh = self.mesh
	var r = self.mesh.get_surface_count()
	if materials.size() < r:
		r = materials.size()
	for m in range(r):
		garment.set_surface_override_material(m,  self.materials[m])
	garment.skin = self.skin
	garment.name = resource_name

	# Apply special material properties
	var applied_effects : Dictionary[String,Node]
	for key in material_override_properties:
		# Support child nodes to manage effects on the mesh. 
		if "DU_effect" in key:
			var effect = key.substr(0, key.find("."))
			var param = key.substr(key.find(".") + 1)
			if effect not in applied_effects:
				var n_effect = DU_effect_bounce.new()
				applied_effects[key] = n_effect
				garment.add_child(n_effect)
			if "." in key: # parse as variable to set
				var thing : DU_effect_bounce = applied_effects[effect]
				thing.set(param, material_override_properties[key])
		else:
			# normal material param
			print("Normal Material param")
			for m in range(mesh.get_surface_count()):
				var mat = garment.get_active_material(m)
				if mat is ShaderMaterial:
					print("Was a shader material")
					mat.set_shader_parameter(key, material_override_properties[key])
				else:
					print("Was not a shader material")
					#assuming StandardMaterial3D
					mat.set(key, material_override_properties[key])

	return garment

func set_garment_property(p_name : String, value : Variant):
	material_override_properties[p_name] = value

func get_garment_property(p_name : String):
	return material_override_properties[p_name]


func serialize() -> String:
	return "GARMENT:" + resource_name + ", tags=" + str(tags) + ", bones=" + str(bones)