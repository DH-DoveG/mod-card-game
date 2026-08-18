extends Node
class_name CorePlayerApi


func get_camp(pid: String) -> Camp:
	var battle: Battle = Utils.get_current_scene()
	var camp_id := ""
	for key in battle.battle_data_bind_list.camp_bind_players:
		if pid in battle.battle_data_bind_list.camp_bind_players[key]:
			camp_id = key
	return battle.camps.get(camp_id)


# CORE内部使用API
# 构建玩家
@rpc("any_peer", "call_remote", "reliable")
func create(pid: String, item: Dictionary, _player_mount: NodePath, camp: String) -> Player:
	var node: Player = null
	# 这里生成玩家的ID（这个ID不会在位数不够时补零）
	#print("create item: ", item)
	var id = item["uid"]
	if not str(id).begins_with("R"):
		assert(not pid.is_empty(), "pid is empty")
		# 如果是人类玩家，那么需要从 GNetManager.players 中获取玩家的信息
		item["avatar"] = GNetManager.players[id].avatar
		item["name"] = GNetManager.players[id].nick
		#node = load("res://entity/human_player/human_player.tscn").instantiate()
		node = HumanPlayer.new()
	else:
		# 如果是机器人玩家，那么需要从 GResourceManager.player_resource 中获取到他的数据
		var f = GResourceManager.player_resource[item["template"]]
		print("Robot: ", f)
		item["avatar"] = f.avatar
		item["name"] = f.name
		item["template"] = item["template"]
		#node = load("res://entity/robot_player/robot_player.tscn").instantiate()
		node = RobotPlayer.new()
	node.name = pid
	#get_node(player_mount).add_child(node)
	# 设置值
	# cbp.append(pid) # 绑定表
	node.set_info(item)
	node.meta["camp"] = camp # lua_meta 信息
	node.meta["id"] = pid

	var battle: Battle = Utils.get_current_scene()
	battle.players[pid] = node
	
	battle.battle_data_bind_list.player_bind_cards_of_controller[pid] = PackedStringArray()
	battle.battle_data_bind_list.player_bind_cards_of_ownership[pid] = PackedStringArray()
	#battle.battle_data_bind_list.player_bind_cards_of_deck[pid] = PackedStringArray()
	#battle.battle_data_bind_list.player_bind_cards_of_hand[pid] = PackedStringArray()
	#battle.battle_data_bind_list.player_bind_cards_of_graveyard[pid] = PackedStringArray()

	return node

# 

# @rpc("any_peer", "call_local", "reliable")
# func set_hand(player_id: String, card_ids: Array, is_adjust: bool) -> void:
# 	var battle: Battle = Utils.get_current_scene()
# 	# 给 card_ids 去重
# 	var uniq = []
# 	# print(battle.uid, ":SET HAND card_ids:", card_ids)
# 	for id in card_ids:
# 		if uniq.find(id) == -1:
# 			uniq.append(id)
# 	# print(battle.uid, ":SET HAND uniq:", uniq)
# 	var _ids = PackedStringArray(uniq)
# 	for _id in _ids:
# 		# battle.battle_data_bind_list.clean_card(_id, [
# 		# 	DataStruct.BattleBindDataSetKey.AREA_BIND_CARDS,
# 		# 	# DataStruct.BattleBindDataSetKey.PLAYER_BIND_CARDS_OF_DECK,
# 		# 	DataStruct.BattleBindDataSetKey.PLAYER_BIND_CARDS_OF_HAND,
# 		# 	# DataStruct.BattleBindDataSetKey.PLAYER_BIND_CARDS_OF_GRAVEYARD
# 		# ])
# 		battle.battle_data_bind_list.clean_card(_id, { "type": null })
# 	battle.battle_data_bind_list.player_bind_cards_of_hand[player_id] = _ids
# 	# if is_adjust:
# 	# 	Utils.adjust_card_heap()


# @rpc("any_peer", "call_local", "reliable")
# func set_graveyard(player_id: String, card_ids: Array, adjusting: bool) -> void:
# 	var battle: Battle = Utils.get_current_scene()
# 	# 给 card_ids 去重
# 	var uniq = []
# 	for id in card_ids:
# 		if uniq.find(id) == -1:
# 			uniq.append(id)
# 	var _ids = PackedStringArray(uniq)
# 	for _id in _ids:
# 		# battle.battle_data_bind_list.clean_card(_id, [
# 		# 	DataStruct.BattleBindDataSetKey.AREA_BIND_CARDS,
# 		# 	# DataStruct.BattleBindDataSetKey.PLAYER_BIND_CARDS_OF_DECK,
# 		# 	DataStruct.BattleBindDataSetKey.PLAYER_BIND_CARDS_OF_HAND,
# 		# 	# DataStruct.BattleBindDataSetKey.PLAYER_BIND_CARDS_OF_GRAVEYARD
# 		# ])
# 		battle.battle_data_bind_list.clean_card(_id, { "type": null })
# 	battle.battle_data_bind_list.player_bind_cards_of_graveyard[player_id] = _ids
# 	for _c in _ids:
# 		var c = FindUtils.find_card(_c)
# 		c.card_info_show.update()
# 	# Utils.adjust_card_heap(true, adjusting)


@rpc("any_peer", "call_local", "reliable")
func set_player_timeout(player_id: String, sec: int, cal: String, cal_net_id: int):
	var player: Player = FindUtils.find_player(player_id)
	if player == null:
		return
	player.set_timeout(sec)
	if cal != "":
		player.round_timer_out_callback = cal
	player.round_timer_out_callback_rpc_id = cal_net_id

@rpc("any_peer", "call_local", "reliable")
func start_player_timeout(player_id: String):
	# print("玩家的时间开始流逝 start_player_timeout:", player_id)
	# FindUtils.find_player(player_id).set_time(true)
	var player = FindUtils.find_player(player_id)
	if GNetManager.uid != 1:
		return
	# print("玩家的时间停止流逝 stop_player_timeout:", player_id)
	# 只有主机会流逝-停止时间
	player.set_time(true)

@rpc("any_peer", "call_local", "reliable")
func stop_player_timeout(player_id: String):
	var player = FindUtils.find_player(player_id)
	if GNetManager.uid != 1:
		return
	# print("玩家的时间停止流逝 stop_player_timeout:", player_id)
	# 只有主机会流逝-停止时间
	player.set_time(false)
