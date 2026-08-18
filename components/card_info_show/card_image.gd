@tool
# This class extends Sprite3D to automatically synchronize its texture
# with a shader parameter named "sprite_texture". This is essential for shaders
# that perform effects based on the sprite’s content, like outlines.
class_name Sprite3dOutlineShader
extends Sprite3D

# Caches the last known material to detect when the entire material has been changed.
# The underscore prefix `_` indicates it’s an internal variable, not meant to be
# modified from outside this script.
var _last_material: ShaderMaterial
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# — The core of the solution for flicker-free updates —
	# Connect to the ‘texture_changed’ signal. This signal is automatically emitted
	# by the Sprite3D node whenever its ‘texture’ property is modified.
	# By connecting our function to it, we ensure the shader is updated *immediately*
	# in the same frame the texture changes, which prevents flickering.
	# This is much more efficient than checking for changes every frame in _process().
	texture_changed.connect(_update_shader_texture)
	# Enable per-frame processing. We still need this to handle the less frequent
	# case where the entire ‘material_override’ is swapped out.
	set_process(true)
	# Perform an initial synchronization when the scene starts.
	# This ensures the shader has the correct texture and material references
	# from the very first frame.
	_update_shader_material()

# Called every frame.
func _process(_delta: float) -> void:
	# Check if the material assigned to ‘material_override’ has changed since the last frame.
	# This can happen if you change it in the editor or via code.
	if material_override != _last_material:
		_update_shader_material()

# This function is called when the material itself is swapped out.
func _update_shader_material() -> void:
	# Update our internal cache with the new material reference.
	_last_material = material_override as ShaderMaterial
	# After a new material is assigned, we must immediately update its
	# texture parameter to match the sprite’s current texture.
	_update_shader_texture()

# This function is the central point for updating the shader’s texture.
# It’s called either by the ‘texture_changed’ signal or when the material is swapped.
func _update_shader_texture() -> void:
	# Safely get the material. The ‘as ShaderMaterial’ will result in `null`
	# if the material is not a ShaderMaterial, preventing crashes.
	var mat = material_override as ShaderMaterial
	# Only proceed if we have a valid shader material AND a valid texture assigned.
	# This prevents errors if either property is unassigned.
	if mat and texture:
		mat.set_shader_parameter("sprite_texture", texture)

# — Public API —
# A helper function to allow other scripts or animations to easily change the line color.
func set_line_color(color: Color) -> void:
	var mat = material_override as ShaderMaterial
	if mat:
		mat.set_shader_parameter("line_color", color)
	else:
	# Provide a helpful warning if the user tries to set a color
	# without a valid material assigned.
		push_warning("Missing ShaderMaterial in material_override – can’t set line_color.")

func enable_outline(enable: bool) -> void:
	var mat = material_override as ShaderMaterial
	if mat:
		mat.set_shader_parameter("enable_outline", enable)
	else:
		# Provide a helpful warning if the user tries to set outline
		# without a valid material assigned.
		push_warning("Missing ShaderMaterial in material_override – can’t set enable_outline.")
