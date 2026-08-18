extends OptionBase


func init_data(type, content) -> void:
	finished.connect(func():
		queue_free()
	)
	$Label.text = type
	
	for cs in content:
		var item = $Template/Item.duplicate(true)
		$Mask/Scroll/List.add_child(item)
		
		var dup = (content[cs] as Array).duplicate_deep()
		dup.sort()
		
		item.set_script(load("res://components/option/option_show_card_set/item.gd"))
		item.init_data(cs, dup)
		item.show()
