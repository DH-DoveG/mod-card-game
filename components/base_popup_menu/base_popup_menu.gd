extends CanvasLayer
class_name BasePopupMenu

# 弹窗菜单分组名，用于在多个弹窗之间协调 _process 的启停
const GROUP_NAME := &"base_popup_menu"

## 弹窗菜单基类：统一处理场景输入锁定、遮罩延申、鼠标移出关闭等公共逻辑。
## 子类需覆写 _get_panel_rect()，返回弹窗面板所在区域的 Rect2。

@onready var mask: ColorRect = $Mask

var mask_rect: Rect2

#static var only = null

func _ready() -> void:
	set_process(false)
	add_to_group(GROUP_NAME)
	#if only:
		#only.queue_free()
		#only = null
	#only = self

func _exit_tree() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.unblock_scene_input(name)
	_restore_topmost_process()

# 锁定场景输入（场景物理、射线、手牌渲染），供子类 set_popup 打开时调用
func block_scene() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.block_scene_input(name)

# 弹出时调用：确认自己是否为组内最顶层，是则关闭其他成员的 _process
func claim_topmost() -> void:
	if not _is_topmost():
		return
	for p in get_tree().get_nodes_in_group(GROUP_NAME):
		if p != self:
			p.set_process(false)

# 组内最顶层 = 场景树中最后一个（最近弹出的）成员
func _is_topmost() -> bool:
	var members = get_tree().get_nodes_in_group(GROUP_NAME)
	return members.is_empty() or members[members.size() - 1] == self

# 离开树时：恢复除自己外顶层成员的 _process
func _restore_topmost_process() -> void:
	var top: Node = null
	for p in get_tree().get_nodes_in_group(GROUP_NAME):
		if p != self and is_instance_valid(p):
			top = p
	if top != null:
		top.set_process(true)

func set_exp_mask(rect: Rect2):
	var panel_rect := _get_panel_rect()
	var mr = make_b_touch_a(panel_rect, rect)
	mask_rect = mr
	$Mask.size = mr.size
	$Mask.position = mr.position

# 让 size.x（宽度）更小的 Rect2 延申来与另一个 Rect2 相连
# 宽度小的一方保持其远离另一方的边缘不动，把邻近边缘延申到与另一方贴合
# inset：允许侵入另一方的像素，0=刚好接触；>0=延申方钻进对方里面
func make_b_touch_a(a: Rect2, b: Rect2, inset: float = 2.0) -> Rect2:
	var a_is_smaller: bool = a.size.x <= b.size.x
	var smaller: Rect2 = a if a_is_smaller else b
	var other: Rect2 = b if a_is_smaller else a
	var result: Rect2 = smaller
	if smaller.position.y <= other.position.y:
		# smaller 在上方：向下延申，让底部连接到 other 的顶部
		var new_end_y: float = other.position.y - inset
		var new_height: float = new_end_y - smaller.position.y
		result.size.y = max(new_height, 0.0)
	else:
		# smaller 在下方：向上延申，让顶部连接到 other 的底部
		var new_top_y: float = other.end.y - inset
		result.position.y = new_top_y
		result.size.y = max(smaller.end.y - new_top_y, 0.0)
	return result

func _process(_delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	if (not mask_rect.has_point(mouse_position)) and (not _get_panel_rect().has_point(mouse_position)):
		queue_free()

func _on_color_rect_gui_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

# 子类实现：返回弹窗面板所在区域的 Rect2
func _get_panel_rect() -> Rect2:
	return Rect2()
