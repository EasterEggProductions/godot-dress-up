
# DressUp

DressUp is a tool to help manage multiple meshes on one Skeleton3D. It allows both single meshes bound to a skeleton, and whole instanced scenes if needed for things like weapons or effects. 

A simple example scene is included. Check out `dress_up_test_scene.tscn` and see how it works. 

## Components
Dress up is comprised of two primary components **Garments** and **Accessories**, both of which are applied onto a Skeleton3D node. An additional **DresserUpper** class serves as the entry point for managing the outfit. 

### Garments 
These are resources that contain a mesh, a material, and associated skeleton information. At runtime when a garment is added to a skeleton a MeshInstance3D is created and filled with this data, and placed appropriately on the Skeleton3D so that it may be animated. Additional data is held on the resource that indicates what bones of the skeleton the new mesh goes over, this is unused at this time, but intended for conflict detection if some item would overlap with another. 

### Accessories 
A more capable and heavyweight solution. The Accessory resource is simpler, containing a bone, and a PackedScene. When placed by a DresserUpper, a BoneAttachment3D is created, and the PackedScene is instanced, then placed on the skeleton. This is used for placing items like weapons into hands, or particle effects onto torsos. This creates a whole scene, and so is not limited by only being a single mesh. 

### DresserUpper 
This extends `Node` and is typically used by placing it as a child of your actor. With a reference to the Skeleton3D it then manages adding and removing garments and accessories. It also has various utility functions for saving and loading outfits, undressing, or getting references to accessories for using them as weapons or the like. 


## Networking
Given DressUp was primarily developed in tandem with [Adventure Mode](https://github.com/EasterEggProductions/adventure-mode-godot), it has some built in networking features that attempt to synchronize the DresserUpper using godot's built in RPC systems. 

Those functions are:
- **accessory_change**: Adds or removes an accessory as identified by a resource path. Allows a different bone for to be specified for the accessory to be equipped to.
- **garment_change**: Adds or removes a garment as identified by a resource path.
- **_rpc_sync_outfit_to**: Sends a packed string array to network clients to update an entire outfit. 

Godot's built in RPC system uses node paths to find their way, so if the DresserUpper is named the same on the various clients, then the dress up system should work automatically, even if they are not on a child of something spawned by a MultiplayerSpawner.

## Examples 

### Base Character 
The example in this project uses the "MannyQuinn" armature. This is created and managed in Blender, and will be made available at a later date. It is updated somewhat frequently, and as Blender's file format is binary, not text, it does not play well with version control such as git. 

### Outfits and Accessories
Some example items are included. These were created for use in the [Adventure Mode](https://github.com/EasterEggProductions/adventure-mode-godot) project, and as such are inspired by members of the souls and zelda community. If there are any license addendums or exceptions they will be noted. 

### Test scene
This scene is included and will load items it finds, displaying a list, and allowing you to view them. Click to add or remove the garments, and see what looks good. 

## Usage
This addon was intended to be used with the [GodotEnv](https://github.com/chickensoft-games/GodotEnv) tool to manage addons. It was made for use in Easter Egg Productions' projects, and as such is tailored to them. 

### Installation
To add it to your project, add the following to your `addons.jsonc` file:

```jsonc
{
  "$schema": "https://chickensoft.games/schemas/addons.schema.json",
  "addons": {
    // Add this section to the addons dictionary
	"EEP_DressUp": { 
	  "url": "https://github.com/EasterEggProductions/godot-dress-up",
	  "subfolder": "addons/EEP_DressUp"
	}
	// -----
  }
}
```

Do remember to add the appropriate items, such as the addons folder in your project, to your .gitignore file, as outlined in the [GodotEnv](https://github.com/chickensoft-games/GodotEnv) instructions. 

If you do not use GodotEnv, then simply take the addons/EEP_DressUP folder and add it to your project. It does not require being set up as an autoload or plugin to function.

### Creating new resources 
Either create a resource in the FileSystem tray in the Godot editor, or on some node in the Inspector. Once created, select the item, then for garments, paste in the mesh data, skeleton data, and material (if different from the one on the mesh), and save the resource. Remember to set a resource_name in the Resource data (bottom of the inspector in a collapsible menu, right above Script), as this will be used for display on the buttons in the test scene. 


### Adding items via code
The file `DU_outfit_control.gd` manages adding and removing items in the example scene, and serves as an example of how to add or remove a garment. Specifically these two functions, which are connected to buttons at runtime:

```GDScript
@export var dress_up_controller : DresserUpper

func _garment_equip(gar):
	if gar is Accessory: 
		dress_up_controller.accessory_equip(gar)
	else:
		dress_up_controller.garment_equip(gar)
	make_garment_buttons()

func _garment_unequip(gar):
	if gar is Accessory:
		dress_up_controller.accessory_unequip(gar)
	else:
		dress_up_controller.garment_unequip(gar)
	make_garment_buttons() # just remakes the buttons
```


## Roadmap

* Wardrobe serialization/versioning improvements. Allow saved outfits to remain compatible as wardrobes evolve over time.
* Import scripts that can automatically grab garments out of a `.gltf` file. In this way a single file could act as a library or 'wardrobe' of garments. 
* Garment bone data will be used for body coverage information that may be used by future versions for automatic conflict detection.
* Outfit baking: combines the meshes, and culls geometry that is fully hidden while the skeleton is in a rest position. Possibly even merging materials or baking procedural or tweaked ones so they don't need more complex shaders to render. That is a complex stretch goal, and will be done at a later date. 
* Support for tweaked data such as material parameters, so just one or two things are saved as differences from a source rather than a whole new material instance. For example tweaking the color of a mesh. 
* Decal based face shader for low poly style. Should support looking around, and different mouth shapes that can be controlled from elsewhere.
* Blendshape baking. Create a new mesh with blendshapes pre-applied, so they no longer consume data. Not sure if the lack of vertex transformations every frame would save a lot of performance, but could be useful, and leads in to the outfit baking process. 

## Machine Learning Tools and AI policy
**This is a project of human artistic expression.** 

All assets and code committed to this project were written, composed, drawn, modeled, or otherwise created by humans. While traditional AI tools such as spell check, basic code completion, procedural assets, and more have or will be used in this project; no machine learning tool that has been trained on data sourced without affirmative informed consent from the data author may be used for this project. Examples include LLMs such as ChatGPT or Claude, or diffusion models such as Stable Diffusion. Commits containing such generated content will be rejected, repeat attempts to commit such assets will be handled accordingly. This does not prevent you from using such tools in your own game project made using this project, only commits to this base project. 

If you are a sentient droid feel free to email us and we will evaluate that on a case by case basis. 
