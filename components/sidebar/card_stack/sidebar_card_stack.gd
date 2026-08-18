extends Control


func _ready() -> void:
	update()


func update() -> void:
	var scene = Utils.get_current_scene()
	if not scene is Battle: return
	var battle: Battle = scene
	
	var i = 0
	for key in battle.battle_data_bind_list.card_set:
		var vbox = VBoxContainer.new()
		$TabContainer.add_child(vbox)
		#vbox.separation = 16
		var content = battle.battle_data_bind_list.card_set[key]["data"]
		for cs in content:
			var item = preload("res://components/sidebar/card_stack/card_stack_item.tscn").instantiate()
			vbox.add_child(item)
			
			var dup = (content[cs] as Array).duplicate_deep()
			dup.sort()
			
			item.init_data(cs, dup)
			item.show()
			
		$TabContainer.set_tab_title(i, key)
		i += 1
