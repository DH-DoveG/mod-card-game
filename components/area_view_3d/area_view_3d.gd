extends StaticBody3D
class_name AreaView3D


var x := 0
var y := 0
var z := 1

var entity: AreaEntity = null

var grid_color := Color("5a5a5a")

func set_entity(meta: AreaEntity):
	entity = meta


func set_color(color: Color):
	var shader: ShaderMaterial = $Body.get_active_material(0)
	shader.set_shader_parameter("grid_color", color)
	grid_color = color


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
	var m: ShaderMaterial = $Body.get_active_material(0)
	var current_color = m.get_shader_parameter("grid_color")
	#var color := Color.from_hsv(current_color.h, current_color.s, 4.416, 1.0)
	var color := Color.from_hsv(current_color.h, current_color.s, 4, 1.0)
	var c = m.get_shader_parameter("grid_color")
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(func(value: Color):
		m.set_shader_parameter("grid_color", value)
	, c, color, 0.2)


func normallight():
	var m: ShaderMaterial = $Body.get_active_material(0)
	var current_color = m.get_shader_parameter("grid_color")
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(func(value: Color):
		m.set_shader_parameter("grid_color", value)
	, current_color, grid_color, 0.4)


func trigger():
	pass


func _ready() -> void:
	add_to_group(&"AreaView3D")


func _exit_tree() -> void:
	remove_from_group(&"AreaView3D")
