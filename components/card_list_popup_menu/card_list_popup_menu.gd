extends CanvasLayer


#完成列表功能以显示卡堆列表
@onready var hbox: HBoxContainer = $CardListPanel/Scroll/HBox
@onready var mask: ColorRect = $Mask
@onready var clp: ColorRect = $CardListPanel

var mask_rect: Rect2

static var only = null

func _ready() -> void:
	set_process(false)
	if only:
		only.queue_free()
		only = null
	only = self

func _exit_tree() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.unblock_scene_input(name)

func set_popup(pos, _cards):
	visible = true
	var scene: Battle = get_tree().current_scene
	#var id = 0
	if not scene.in_option:
		_build_card_view_2d(_cards)
	await get_tree().process_frame
	pos.x -= clp.size.x / 4
	#pos.y -= clp.size.y
	clp.position = pos
	clp.position = pos
	if hbox.get_child_count() == 0:
		pass
	if scene is Battle:
		scene.block_scene_input(name)
	$ColorRect2.size = clp.size
	$ColorRect2.position = clp.position
	print("SP pos: ", pos, " | size: ", clp.size)

func set_exp_mask(rect: Rect2):
	var mr = make_b_touch_a(clp.get_rect(), rect)
	mask_rect = mr
	#mask_rect = rect
	$Mask.size = mr.size
	$Mask.position = mr.position
	#$Mask.size = rect.size
	#$Mask.position = rect.position
	print("MR1: ", rect)
	print("MR2: ", mr)

# 让shape.x（宽度）更小的Rect2延申来与另一个Rect2相连
# 宽度小的一方保持其远离另一方的边缘不动，把邻近边缘延申到与另一方贴合
# inset：允许侵入另一方的像素，0=刚好接触；>0=延申方钻进对方里面
func make_b_touch_a(a:Rect2, b:Rect2, inset:float = 2.0) -> Rect2:
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
	#print("!!!")
	var mouse_position := get_viewport().get_mouse_position()
	#print(">> ", mask_rect.has_point(mouse_position), " | ", clp.get_rect().has_point(mouse_position))
	if (not mask_rect.has_point(mouse_position)) and (not clp.get_rect().has_point(mouse_position)):
		queue_free()
		pass

func _on_color_rect_gui_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _build_card_view_2d(cards):
	for id in cards:
		var ce = FindUtils.find_card(id)
		var cv2d: CardView2D = preload("res://components/card_view_2d/card_view_2d.tscn").instantiate()
		cv2d.custom_maximum_size = Vector2(84, 84)
		cv2d.custom_minimum_size = Vector2(84, 84)
		hbox.add_child(cv2d)
		cv2d.set_card(ce)
		cv2d.check_menu()

func _clear():
	for cv in hbox.get_children():
		cv.queue_free()

func _on_close_pressed() -> void:
	_clear()
	hide()

func _event_bus_callable(args) -> void:
	if typeof(args) == TYPE_DICTIONARY:
		_clear()
		if args["params"] is Array:
			show()
			$Count/Label.text = str(args["params"].size())
			_build_card_view_2d(args["params"])
