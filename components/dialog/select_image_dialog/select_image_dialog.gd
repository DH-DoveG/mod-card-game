extends SelectItemDialog

# 这里只展示给定的 Tags 的图片资源

func _build_list(list: Dictionary) -> void:
	items = list["items"]
	max_num = list["max"]
	min_num = list["min"]
	
	# 在这里，items 就是Tag列表（不过我们不能混合的显示，我们只能单一的显示，所以取第一个作为tag）
	var tag = items[0]
	
	var item_size = Vector2.ZERO
	match tag:
		"OTHER": item_size = Vector2(369, 369)
		"CARD_BACK": item_size = Vector2(253, 369)
		"CARD_FRONT": item_size = Vector2(253, 369)
		"STANDING_SIGN": item_size = Vector2(253, 369)
		"CARD_STANDING_SIGN": item_size = Vector2(369, 369)
		"AVATAR": item_size = Vector2(369, 369)
		"BACKGROUND": item_size = Vector2(656, 369)
	temp_item.custom_minimum_size = item_size
	temp_item.custom_maximum_size = item_size
	
	items = []
	for k1 in GResourceManager.image_resource:
		if tag in k1.tags:
			items.append(k1)
	
	for item in items:
		var dup = temp_item.duplicate(true)
		scroll.add_child(dup)
		dup.get_node("Image").texture_normal = item.resource
		dup.get_node("Label").text = item.id
		dup.get_node("Image").pressed.connect(_list_item_pressed.bind(dup, {
			"value": item
		}))
		dup.show()
