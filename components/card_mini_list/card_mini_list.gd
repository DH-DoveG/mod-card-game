extends Panel


@onready var title = $Title
@onready var list = $VBox/Scroll/VBox
@onready var item_template = $Template/Item


func set_title(context: String) -> void:
	title.text = context


# context: CardID Array
func set_list(context: Array) -> void:
	for i in list.get_children():
		i.queue_free()
	var index = 0
	var battle: Battle = Utils.get_current_scene()
	for i in context:
		index += 1
		
		if not CardUtils.check_card_can_look_info(i, battle.host_player_id):
			continue
		
		var c = FindUtils.find_card(i)
		if c == null:
			continue
		var item = item_template.duplicate()
		item.name = i
		list.add_child(item)
		item.show()
		item.get_node("./Index/Label").text = str(index)
		var cv: CardView3D = item.get_node("./CardView")
		cv.set_card(c)
		cv.set_menu(true)
	if list.get_child_count() == 0:
		hide()


func update(info: Dictionary) -> void:
	var s = info.get("show")
	var _title = info.get("title")
	var _list = info.get("list")
	
	if s: visible = s
	if _title: set_title(_title)
	if _list: set_list(_list)


func _on_close_pressed() -> void:
	hide()
	for i in list.get_children():
		i.queue_free()
