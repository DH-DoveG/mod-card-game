extends ColorRect

# 收缩状态：
# box size: (1408, 288)
# grid size: (1264, 200)

# 展开状态：
# box size: (1408, 928)
# grid size: (1280, 848)

# 收缩时是 横着滑 展开后是 竖着滑


var is_expand = false


func init_data(player_id: String, card_ids: Array) -> void:
	for cid in card_ids:
		add_card_view(cid)
	var player: Player = FindUtils.find_player(player_id)
	$PlayerName/Label.text = player.player_name
	$Count/Label.text = "Count: " + str(card_ids.size())
	var grid = $Scroll/Grid
	var hbox = $Scroll/Hbox
	$Switch.pressed.connect(func():
		is_expand = not is_expand
		if is_expand:
			custom_minimum_size.y = 312
			size.y = 312
			$Scroll.size.y = 264
			$Switch.texture_normal = load("res://addons/material_icons_importer/icons/keyboardArrowUp.png")
			for node in hbox.get_children():
				hbox.remove_child(node)
				grid.add_child(node)
			grid.show()
			hbox.hide()
		else:
			custom_minimum_size.y = 144
			size.y = 144
			$Scroll.size.y = 96
			$Switch.texture_normal = load("res://addons/material_icons_importer/icons/keyboardArrowDown.png")
			for node in grid.get_children():
				grid.remove_child(node)
				hbox.add_child(node)
			grid.hide()
			hbox.show()
	)


func add_card_view(card_id: String) -> void:
	var grid = $Scroll/Grid
	var hbox = $Scroll/Hbox
	var cv = load("res://components/card_view_2d/card_view_2d.tscn").instantiate()
	cv.custom_minimum_size = Vector2(58, 81)
	cv.custom_maximum_size = Vector2(58, 81)
	cv.size = Vector2(58, 81)
	cv.mouse_filter = MOUSE_FILTER_PASS
	if is_expand:
		grid.add_child(cv)
	else:
		hbox.add_child(cv)
	cv.show()
	var card: CardEntity = FindUtils.find_card(card_id)
	# cv.texture_normal = GResourceManager.get_image_resoure(card.image)
	cv.set_card(card, true)
	cv.check_menu()
