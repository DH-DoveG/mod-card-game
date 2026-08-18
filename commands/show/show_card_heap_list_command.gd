extends Command
class_name ShowCardHeapListCommand

func execute() -> void:
	# 参数检查
	if typeof(_args) != TYPE_DICTIONARY:
		return
	if not _args.has("card") and typeof(_args["card"]) != TYPE_STRING:
		return
	if not _args.has("pos") and typeof(_args["pos"]) != TYPE_VECTOR2:
		return
	
	var cid = _args["card"]
	
	var area = GApiManager.card_api.get_area(cid)
	
	var battle: Battle = Utils.get_current_scene()
	var heap = []
	var title = ""
	if area["area_id"] == null:
		var _pid = GApiManager.card_api.get_ownership(cid)
		#for hdg: HDGView in battle.scene.hdg_mount.get_children():
		#	if hdg.user.name == pid:
		#		match area["type"]:
		#			"Hand":
		#				FindUtils.find_card(cid).trigger_behavior_menu()
		#				return
		#			"Deck":
		#				area = hdg.deck
		#				heap = battle.battle_data_bind_list.player_bind_cards_of_deck[pid]
		#				title = "卡组\n(" + pid + ")"
		#			"Graveyard":
		#				area = hdg.graveyard
		#				heap = battle.battle_data_bind_list.player_bind_cards_of_graveyard[pid]
		#				title = "弃区\n(" + pid + ")"
	else:
		area = FindUtils.find_area(area["area_id"])
		if area:
			heap = GApiManager.area_api.get_heap(area.name)
			title = area.name
	
	if heap.size() > 1:
		# 显示列表
		battle.get_node("./UI/CardMiniList").update({
			"title": title,
			"list": heap,
			"show": true
		})
		return
	
	#battle.get_node("./UI/CardMiniList").update({
			#"title": "",
			#"list": [],
			#"show": false
	#})
	FindUtils.find_card(cid).trigger_behavior_menu()

func undo() -> void:
	pass
