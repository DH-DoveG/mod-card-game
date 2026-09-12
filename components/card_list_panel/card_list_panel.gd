extends ColorRect


#完成列表功能以显示卡堆列表
@onready var vbox: VBoxContainer = $Scroll/VBox


# CardEntity[]
func set_data(cards: Array, area_id: String):
	_build_card_view_2d(cards)
	$AreaID/Label.text = area_id
	$Count/Label.text = cards.size()


func _build_card_view_2d(cards):
	for ce: CardEntity in cards:
		# CardView2D 节点最小尺寸定为 (88, 110)
		var cv2d: CardView2D = preload("res://components/card_view_2d/card_view_2d.tscn").instantiate()
		vbox.add_child(cv2d)
		cv2d.set_card(ce)


func _clear():
	for cv in vbox.get_children():
		cv.queue_free()


func _on_close_pressed() -> void:
	_clear()
	hide()
