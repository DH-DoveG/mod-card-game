extends Object
class_name Utils


# 获取节点的实体
static func get_node_entity(node: Node) -> Entity:
	# return node.get_node("Entity")
	return node.entity


# 判断当前场景是否是 Battle
static func is_battle_scene() -> bool:
	var scene = Utils.get_current_scene()
	if not is_instance_valid(scene): return false
	if scene is not Battle: return false
	return true


static func get_scene_tree() -> SceneTree:
	return Engine.get_main_loop()


static func get_current_scene() -> Node:
	return Engine.get_main_loop().current_scene


static func calibration_direction(v) -> int:
	# v 的取值范围在 -180 ~ 180
	# 需要四舍五入的校准 v 的值在 0, 90, 180, -90, -180 这5 个值中
	if v > -45 and v < 45:
		return 0
	elif v > 45 and v < 135:
		return 90
	elif v > 135:
		return 180
	elif v > -135 and v < -45:
		return -90
	else:
		return -180


# 卡片变动时的调整刷新
#static func adjust_card_heap(deck_adjusting = true, graveyard_adjusting = true) -> void:
	#var battle: Battle = Utils.get_current_scene()
	#for hdg in battle.scene.hdg_mount.get_children():
		#hdg.update_hand()
		#hdg.update_deck(deck_adjusting)
		#hdg.update_graveyard(graveyard_adjusting)
