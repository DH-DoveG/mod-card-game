extends Node
class_name CoreCardSetApi


# 这个会创建一个卡片集
@rpc("any_peer", "call_local", "reliable")
func create(card_set_id: String, config: Dictionary = {}) -> void:
	# print("Card set create: ", card_set_id)
	var battle: Battle = Utils.get_current_scene()
	var players = battle.battle_data_bind_list.player_bind_cards_of_controller.keys()
	var card_set = {}
	for player in players:
		card_set[player] = []
	battle.battle_data_bind_list.card_set[card_set_id] = {
		"config": config,
		"data": card_set,
	}
	#battle.get_node("UI/PlayerHandView").check(card_set_id, config)
	#__update()
	battle.event_manager.emit("CardSetCreate", {
		"set_key": card_set_id,
		"config": config
	})


@rpc("any_peer", "call_local", "reliable")
func remove() -> void:
	pass


func find_card(card_id: String) -> Variant:
	var battle: Battle = Utils.get_current_scene()
	for key in battle.battle_data_bind_list.card_set:
		for pid in battle.battle_data_bind_list.card_set[key]["data"]:
			# print(pid, " >> ", battle.battle_data_bind_list.card_set[key]["data"][pid])
			if card_id in battle.battle_data_bind_list.card_set[key]["data"][pid]:
				return {
					"type": key,
					"player": pid
				}
	return null


@rpc("any_peer", "call_local", "reliable")
func erase(cards):
	var battle: Battle = Utils.get_current_scene()
	for key in battle.battle_data_bind_list.card_set:
		for pid in battle.battle_data_bind_list.card_set[key]["data"]:
			var arr: Array = battle.battle_data_bind_list.card_set[key]["data"][pid]
			arr.filter(func(item):
				return item not in cards
			)
	for card in cards:
		var remove_sets := battle.battle_data_bind_list.clean_card(card)
		for sets_key in remove_sets:
			battle.event_manager.emit("CardSetUpdate", {
				"set_key": sets_key["sets"],
				"player_id": sets_key["pid"],
				"sets": battle.battle_data_bind_list.card_set[sets_key["sets"]]
			})


@rpc("any_peer", "call_local", "reliable")
func append(card_set_id: String, player_id: String, cards: Array) -> void:

	# print("[CORE] card_set append > csi: ", card_set_id, " | pi: ", player_id, " | cards: ", cards)

	var battle: Battle = Utils.get_current_scene()
	#battle.battle_data_bind_list.card_set[card_set_id]["data"][player_id].append_array(cards)
	for key in battle.battle_data_bind_list.card_set:
		for pid in battle.battle_data_bind_list.card_set[key]["data"]:
			var arr: Array = battle.battle_data_bind_list.card_set[key]["data"][pid]
			arr.filter(func(item):
				return item not in cards
			)
	for card in cards:
		var remove_sets := battle.battle_data_bind_list.clean_card(card, {"type": "card_set", "save": {"pid": player_id, "set": card_set_id}})
		#FindUtils.find_card(card).remove_all_view_3d()
		for sets_key in remove_sets:
			battle.event_manager.emit("CardSetUpdate", {
				"set_key": sets_key["sets"],
				"player_id": sets_key["pid"],
				"sets": battle.battle_data_bind_list.card_set[sets_key["sets"]]
			})
		
		#这里还得确认卡片是在 card_set 还是 场上
		#（没有3D视图可以说一定在 card_set 里）
		
		#for view in FindUtils.find_card(card).get_view_3d():
			#view.animate_free()
		#for view in FindUtils.find_card(card).get_view_2d():
			#view.animate_free()
		# FIXME: 这里要使用一个动画效果
		# 让 CardView3D 到 CardSet 的对应 Panel 添加线段（杀戮尖塔风格）
		#var animate: Animate = preload("res://animate/animate_card_to_set.tscn").instantiate()
		#battle.add_child(animate)
		#animate.play()
		
		# FindUtils.find_card(card).card_hide()
	 #battle.battle_data_bind_list.card_set[card_set_id]["data"][player_id] = cards
	battle.battle_data_bind_list.card_set[card_set_id]["data"][player_id].append_array(cards)
	# print("CS:", card_set_id, " PID:", player_id, " CIDS:", cards, " >> ", battle.battle_data_bind_list.card_set[card_set_id]["data"][player_id])
	battle.event_manager.emit("CardSetUpdate", {
		"set_key": card_set_id,
		"player_id": player_id,
		"sets": battle.battle_data_bind_list.card_set[card_set_id]
	})
	#__update()


@rpc("any_peer", "call_local", "reliable")
func reset(card_set_id: String, player_id: String, cards: Array) -> void:
	var battle: Battle = Utils.get_current_scene()
	# 查重
	for key in battle.battle_data_bind_list.card_set:
		for pid in battle.battle_data_bind_list.card_set[key]["data"]:
			var arr: Array = battle.battle_data_bind_list.card_set[key]["data"][pid]
			arr.filter(func(item):
				return item not in cards
			)
	for card in cards:
		
		# 这里应该也触发 CardSetUpdate 事件
		# clean_card 从哪个 sets 中删掉就做记录
		
		var remove_sets := battle.battle_data_bind_list.clean_card(card, {"type": "card_set", "save": {"pid": player_id, "set": card_set_id}})
		for sets_key in remove_sets:
			battle.event_manager.emit("CardSetUpdate", {
				"set_key": sets_key["sets"],
				"player_id": sets_key["pid"],
				"sets": battle.battle_data_bind_list.card_set[sets_key["sets"]]
			})
		
		#FindUtils.find_card(card).remove_all_view_3d()
		#for view in FindUtils.find_card(card).get_view_3d():
			#view.animate_free()
		#for view in FindUtils.find_card(card).get_view_2d():
			#view.animate_free()
		#FindUtils.find_card(card).card_hide()
	battle.battle_data_bind_list.card_set[card_set_id]["data"][player_id] = cards
	#
	battle.event_manager.emit("CardSetUpdate", {
		"set_key": card_set_id,
		"player_id": player_id,
		"sets": battle.battle_data_bind_list.card_set[card_set_id]
	})
	#__update()


func list(card_set_id: String, player_id: String) -> Variant:
	# print("[CORE] card_set list > card_set_id: ", card_set_id, " | player_id: ", player_id)
	var battle: Battle = Utils.get_current_scene()
	if player_id == null:
		return battle.battle_data_bind_list.card_set[card_set_id]["data"]
	return battle.battle_data_bind_list.card_set[card_set_id]["data"][player_id]

#
#static func __update() -> void:
	#var battle: Battle = Utils.get_current_scene()
	#battle.get_node("UI/CardSetInfoPanel").update()
	#battle.get_node("UI/PlayerHandView").update()
