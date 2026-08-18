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


func _ready() -> void:
	add_to_group(&"AreaView3D")


func _exit_tree() -> void:
	remove_from_group(&"AreaView3D")
