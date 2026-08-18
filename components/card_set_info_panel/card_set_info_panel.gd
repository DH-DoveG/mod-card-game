extends ColorRect


var battle: Battle = null


func set_battle(_battle: Battle) -> void:
	battle = _battle
	battle.event_manager.subscribe("CardSetCreate", _create)


func _create(args: Dictionary):
	var set_key = args["set_key"]
	var sets = battle.battle_data_bind_list.card_set[set_key]
	var panel = load("res://components/card_set_info_panel/card_set_expend_panel.tscn").instantiate()
	panel.name = args["set_key"]
	$Content.add_child(panel)
	panel.set_battle(battle)
	panel.show_card_set(sets, set_key)

#
#func update():
	## 模板： { "Hand": { 
	##             "config": {...}, 
	##             "data": { "PlayerID1": ["CardID1"...], "PlayerID2": ["CardID2"...] } 
	##       } }
	#for card_set_key in battle.battle_data_bind_list.card_set:
		#var sets = battle.battle_data_bind_list.card_set[card_set_key]
		#var panel = $Content.get_node(card_set_key)
		#if panel:
			#panel.update(sets, card_set_key)
		#else:
			#panel = load("res://components/card_set_info_panel/card_set_expend_panel.tscn").instantiate()
			#panel.name = card_set_key
			#$Content.add_child(panel)
			#panel.show_card_set(sets, card_set_key)
