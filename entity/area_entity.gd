extends Entity
class_name AreaEntity


var x := 0
var y := 0
var z := 0


func get_position() -> Vector3:
	#var battle = Utils.get_current_scene()
	#if battle is not Battle:
		#return Vector3.ZERO
	#var item: int = battle.scene.map.get_cell_item(Vector3i(x, 0, y))
	#var height: float = battle.scene.get_mesh_local_height(item)
	#var pos = battle.scene.map.map_to_local(Vector3i(x, 0, y))
	#pos.y += height
	var views = get_view_3d()
	#print("VIEWS : ", views)
	if views.is_empty():
		return Vector3.ZERO
	var view: AreaView3D = views.front()
	#var pos = view.global_position
	#print("POS: ", pos)
	#return view.global_position
	return view.get_top()


func get_view_3d(if_null_to_create: bool = false) -> Array[AreaView3D]:
	var result: Array[AreaView3D] = []
	var views = Utils.get_scene_tree().get_nodes_in_group(&"AreaView3D")
	#print("GV3D : ", views)
	for view: AreaView3D in views:
		if view.entity == self:
			result.append(view)
	
	if if_null_to_create:
		var battle = Utils.get_current_scene()
		if battle is Battle:
			var view = battle.scene.add_area(x, y, z)
			view.set_entity(self)
	return result
