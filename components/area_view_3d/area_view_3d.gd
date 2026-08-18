extends StaticBody3D
class_name AreaView3D


var x := 0
var y := 0
var z := 1

var entity: AreaEntity = null


func set_entity(meta: AreaEntity):
	entity = meta


func set_height(level: int):
	z = level
	if z == 0:
		hide()
		$CS3D.scale.y = 0.1
		return
	$Body.scale.y = 0.1 * level
	$Body.position.y = 0.05 * level
	$CS3D.shape.size.y =  0.1 * level
	$CS3D.position.y = 0.05 * level


func get_top():
	var pos = global_position
	pos.y += 0.1 * z
	return pos


func hightlight():
	var am: ArrayMesh = $Body.mesh
	var m: ShaderMaterial = am.surface_get_material(0)
	#var m: ShaderMaterial = $Body.mesh
	#.get_surface_override_material(0)
	var color := Color.from_hsv(0.0, 0.0, 4.416, 1.0)
	#m.set_shader_parameter("grid_color", color)
	var c = m.get_shader_parameter("grid_color")
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(func(value: Color):
		m.set_shader_parameter("grid_color", value)
	, c, color, 0.2)


func normallight():
	var am: ArrayMesh = $Body.mesh
	var m: ShaderMaterial = am.surface_get_material(0)
	#var m: ShaderMaterial = $Body.mesh.get_surface_override_material(0)
	
	var c = m.get_shader_parameter("grid_color")
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(func(value: Color):
		m.set_shader_parameter("grid_color", value)
	, c, Color("c8c8c8"), 0.4)
	
	#m.set_shader_parameter("grid_color", Color("c8c8c8"))


func trigger():
	pass


func _ready() -> void:
	add_to_group(&"AreaView3D")


func _exit_tree() -> void:
	remove_from_group(&"AreaView3D")
