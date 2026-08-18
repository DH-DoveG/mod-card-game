extends Entity
class_name CardEntity

signal card_changed(_item: String, _ce: CardEntity)

var is_front = false: # 是否是正面朝上
	set(v):
		is_front = v
		emit_signal("card_changed", "front", self)
var is_orientation = false: # 是否是朝向正常（true标识正常，也就是通常我们说的面向玩家的方向）
	set(v):
		is_orientation = v
		emit_signal("card_changed", "orientation", self)
# 卡名
var card_name = "":
	set(v):
		card_name = v
		emit_signal("card_changed", "card_name", self)
# 卡图
var image = "":
	set(v):
		image = v
		emit_signal("card_changed", "image", self)
# 卡片立绘
var standing_sign = "":
	set(v):
		standing_sign = v
		emit_signal("card_changed", "standing_sign", self)


func get_code():
	return meta["entity"]["code"]


func get_view_3d(if_null_to_create: bool = false) -> Array[CardView3D]:
	var result: Array[CardView3D] = []
	var card_views = Utils.get_scene_tree().get_nodes_in_group(&"CardView3D")
	for view: CardView3D in card_views:
		if view.entity == self:
			result.append(view)
	
	if if_null_to_create:
		var scene = Utils.get_current_scene()
		if scene is Battle:
			var view: CardView3D = load("res://components/card_view_3d/card_view_3d.tscn").instantiate()
			scene.scene.card_mount.add_child(view)
			# view.card_hide()
			view.hide()
			view.set_entity(self)
			result.append(view)
	
	return result


func get_view_2d() -> Array[CardView2D]:
	var result: Array[CardView2D] = []
	var card_views = Utils.get_scene_tree().get_nodes_in_group(&"CardView2D")
	for view: CardView2D in card_views:
		if view.entity == self:
			result.append(view)
	
	return result


func remove_all_view_3d():
	for view in get_view_3d():
		view.queue_free()
