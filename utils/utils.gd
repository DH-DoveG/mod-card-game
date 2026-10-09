extends Object
class_name Utils

# 获取节点的实体
static func get_node_entity(node: Node) -> Entity:
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

# 实验性功能
# 把Rect2从中心对半切割
# rect: 原始矩形
# is_horizontal: true=横切(上下), false=竖切(左右)
static func split_rect_center(rect: Rect2, is_horizontal: bool) -> Array:
	var result: Array = []
	if is_horizontal:
		# 横切：水平方向切割，分成上下两块
		var half_height: float = rect.size.y / 2.0
		var rect_top: Rect2 = Rect2(rect.position, Vector2(rect.size.x, half_height))
		var rect_bottom: Rect2 = Rect2(rect.position + Vector2(0, half_height), Vector2(rect.size.x, half_height))
		result.append(rect_top)
		result.append(rect_bottom)
	else:
		# 竖切：垂直方向切割，分成左右两块
		var half_width: float = rect.size.x / 2.0
		var rect_left: Rect2 = Rect2(rect.position, Vector2(half_width, rect.size.y))
		var rect_right: Rect2 = Rect2(rect.position + Vector2(half_width, 0), Vector2(half_width, rect.size.y))
		result.append(rect_left)
		result.append(rect_right)
	return result
