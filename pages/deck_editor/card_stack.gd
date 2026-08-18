extends Panel

@onready var grid = $Grid

var show_cvo = null

var show_ao = false
var ao_card_entity = null


func get_title() -> String:
	return $Top/LineEdit.text


#点击搜索栏的卡片的加号，这里会显示，除非再点击那个卡片的减号，或者那个项目消失时关闭显示
func show_add_card(card: CardEntity, status: bool) -> void:
	if not status:
		ao_card_entity = null
		if grid.get_node("AddOption"):
			grid.get_node("AddOption").queue_free()
	else:
		ao_card_entity = card
		if not grid.get_node("AddOption"):
			var ta = $Template/AddOption.duplicate(true)
			ta.name = "AddOption"
			grid.add_child(ta)
			ta.show()
			ta.get_node("Info").pressed.connect(func():
				# 这里不拷贝可能会有问题，但是尽可能不拷贝，因为不拷贝都用一份卡片实体性能比较好
				add_card(ao_card_entity)
				grid.move_child(ta, grid.get_child_count())
			)
	update()


func add_card(card: CardEntity) -> void:
	var cv: CardView2D = load("res://components/card_view/card_view.tscn").instantiate()
	grid.add_child(cv)
	cv.custom_minimum_size = Vector2(130, 182)
	cv.custom_maximum_size = Vector2(130, 182)
	cv.set_card(card, false)
	cv.mouse_entered.connect(func():
		if show_cvo: show_cvo.queue_free()
		var cvo = $Template/CVOption.duplicate(true)
		cv.add_child(cvo)
		show_cvo = cvo
		cvo.show()
		cvo.get_node("VBox/Info").pressed.connect(func():
			print("CVO Info")
		)
		cvo.get_node("VBox/Remove").pressed.connect(func():
			remove_card(cv.get_index())
		)
		cvo.show()
	)
	cv.mouse_exited.connect(func():
		if show_cvo: show_cvo.queue_free()
	)
	update()


func remove_card(index: int) -> void:
	#for cv in grid.get_children():
		#if cv is CardView and cv.data == card:
			#cv.queue_free()
			#break
	grid.get_children()[index].queue_free()
	update()


func update():
	get_tree().process_frame.connect(func():
		# ceili | floori
		var gsy = float(grid.get_child_count()) / float(10)
		if not is_zero_approx(gsy):
			gsy = ceili(gsy)
		if gsy == 0: gsy = 1
		custom_minimum_size.y = 246 + gsy * 182 - 182 + gsy * 8
	, ConnectFlags.CONNECT_ONE_SHOT)


func _on_remove_pressed() -> void:
	queue_free()
