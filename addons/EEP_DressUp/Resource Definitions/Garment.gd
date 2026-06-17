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
	return garment

func set_garment_property(p_name : String, value : Variant):
	material_override_properties[p_name] = value

func get_garment_property(p_name : String):
	return material_override_properties[p_name]


func serialize() -> String:
	return "GARMENT:" + resource_name + ", tags=" + str(tags) + ", bones=" + str(bones)