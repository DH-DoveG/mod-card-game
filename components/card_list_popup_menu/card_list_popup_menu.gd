extends BasePopupMenu


#完成列表功能以显示卡堆列表
@onready var hbox: HBoxContainer = $CardListPanel/Scroll/HBox
@onready var clp: ColorRect = $CardListPanel

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
	block_scene()
	claim_topmost()
	$ColorRect2.size = clp.size
	$ColorRect2.position = clp.position
	print("SP pos: ", pos, " | size: ", clp.size)

func _get_panel_rect() -> Rect2:
	return clp.get_rect()

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
