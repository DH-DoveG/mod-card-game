extends Node
class_name CoreCardApi


func create_entity(card_id: String, card_resource_id: String) -> CardEntity:
	var card_meta = ModManager.do_mod_file(GResourceManager.card_resource[card_resource_id]).invoke()
	card_meta["entity"]["id"] = card_id
	#var ce = preload("res://entity/card_entity/card_entity.tscn").instantiate()
	var ce = CardEntity.new()
	#Utils.get_current_scene().add_child(ce)
	ce.name = card_id
	ce.image = card_meta["image"]
	ce.standing_sign = card_meta["standing_sign"]
	ce.card_name = card_meta["name"]
	ce.meta = card_meta
	return ce


@rpc("any_peer", "call_local", "reliable")
#func create_battle(card_id: String, card_resource_id: String, card_mount: NodePath, card_owner: String, card_back = "DEFAULT_CARD_BACK") -> CardEntity:
func create_battle(card_id: String, card_resource_id: String, card_owner: String) -> CardEntity:
	var ce = create_entity(card_id, card_resource_id)

	#var card_meta = ModManager.do_mod_file(GResourceManager.card_resource[card_resource_id]).invoke()
	#card_meta["id"] = card_id
	#var card_image = card_meta["image"]
	#var card_standing_sign = card_meta["standing_sign"]
	#var card = CardUtils.create(card_id, card_meta, get_node(card_mount))
	
	var battle: Battle = Utils.get_current_scene()
	battle.battle_data_bind_list.player_bind_cards_of_ownership[card_owner].append(card_id)
	battle.battle_data_bind_list.player_bind_cards_of_controller[card_owner].append(card_id)
	battle.battle_data_bind_list.card_bind_behaviors[card_id] = PackedStringArray()
	battle.battle_data_bind_list.card_public_information[card_owner].append(card_id)
	
	# print("CARD OWNER: ", card_owner, " | CARD ID: ", card_id)
	
	# card.is_front = false
	# card.image = card_image
	# card.standing_sign = card_standing_sign
	# card.card_name = card_meta["name"]
	# card_meta["entity"]["id"] = card_id
	# 为卡片添加图片
	#var card_front_image = GResourceManager.get_image_resoure(ce.image)
	#var card_back_image = GResourceManager.get_image_resoure(card_back)
	
	#CardUtils.translate_image(card, card_front_image.get_image(), card_back_image.get_image())
	#for behavior in ce.meta["entity"]["behaviors"].to_array():
	for behavior in ce.behavior_manager.behaviors:
		#var behavior_lua = GApiManager.behavior_api.create(behavior)
		# print("<< ", behavior)
		#ce.behavior_manager.add_behavior(behavior_lua)
		# card.entity.behavior_manager.add_behavior(behavior_lua)
		#battle.battle_data_bind_list.card_bind_behaviors[card_id].append(behavior_lua.name)
		#battle.behaviors[behavior_lua.name] = behavior_lua
		battle.battle_data_bind_list.card_bind_behaviors[card_id].append(behavior.name)
		battle.behaviors[behavior.name] = behavior
	#return card
	return ce


func create_3d_view(card_entity: CardEntity, card_mount: NodePath) -> CardView3D:
	# 给卡片创建 3D 视图
	#var card: CardView3D = CardUtils.create(card_entity.meta["entity"]["id"], card_entity, get_node(card_mount))
	var card: CardView3D = load("res://components/card_view_3d/card_view_3d.tscn").instantiate()
	# card.card_hide()
	card.hide()
	#
	card.set_entity(card_entity)
	
	get_node(card_mount).add_child(card)
	
	#card.is_front = false
	#card.image = card_image
	#card.standing_sign = card_standing_sign
	#card.card_name = card_meta["name"]
	#card_meta["entity"]["id"] = card_id
	#为卡片添加图片
	#var card_front_image = GResourceManager.get_image_resoure(ce.image)
	#var card_back_image = GResourceManager.get_image_resoure(card_back)
	#CardUtils.translate_image(card, card_front_image.get_image(), card_back_image.get_image())
	
	return card


@rpc("any_peer", "call_local", "reliable")
func set_border_color(card_id: String, color: Color) -> void:
	var card = FindUtils.find_card(card_id)
	if card is not CardEntity:
		return
	card.set_outline_color(color)


# front: true card_id 给所有玩家可见; false card_id 仅给卡片的持有者可见
@rpc("any_peer", "call_local", "reliable")
func set_public_information(card_id: String, front: bool):
	var battle = Utils.get_current_scene()
	if battle is Battle:
		var player_id = GApiManager.card_api.get_ownership(card_id)
		for pid in battle.battle_data_bind_list.card_public_information:
			if front:
				var index = battle.battle_data_bind_list.card_public_information[pid].find(card_id)
				if index == -1:
					battle.battle_data_bind_list.card_public_information[pid].push_back(card_id)
			else:
				if pid != player_id:
					var index = battle.battle_data_bind_list.card_public_information[pid].find(card_id)
					if index != -1:
						battle.battle_data_bind_list.card_public_information[pid].remove_at(index)


func get_public_information(player_id: String, card_id: String) -> bool:
	var battle = Utils.get_current_scene()
	if battle is Battle:
		for pid in battle.battle_data_bind_list.card_public_information:
			if pid == player_id:
				var index = battle.battle_data_bind_list.card_public_information[pid].find(card_id)
				if index:
					return true
	return false


@rpc("any_peer", "call_local", "reliable")
func set_front(card_id: String, front: bool) -> void:
	var card: CardEntity = FindUtils.find_card(card_id)
	if card is not CardEntity:
		return
	# card.is_front = front
	# card.entity.is_front = front
	card.is_front = front
	#card.card_info_show.update()
	
	rpc("set_public_information", card_id, front)
	# FIXME: 这里需要找到 CardEntity 对应的 CardView3D
	#adjust_card_rotation(card)


@rpc("any_peer", "call_local", "reliable")
func set_orientation(card_id: String, orientation: bool) -> void:
	var card = FindUtils.find_card(card_id)
	if card is not CardEntity:
		return
	var view_3d = card.get_view_3d()[0]
	# card.is_orientation = orientation
	# card.entity.is_orientation = orientation
	card.is_orientation = orientation
	#card.card_info_show.update()
	adjust_card_rotation(view_3d)


@rpc("any_peer", "call_local", "reliable")
func set_area(card_id: String, area_id: String, config: Dictionary = {}) -> void:
	var card: CardEntity = FindUtils.find_card(card_id)
	var area: AreaEntity = FindUtils.find_area(area_id)
	
	var play_sound = config.get("play_sound", null)
	if play_sound:
		GApiManager.resource_api.play_sound(play_sound)

	if not card or not area:
		return
	
	
	#这里拍卡后 CardSet 没有更新
	#CardSet 的更新事件策略存在设计上的问题
	GApiManager.card_set_api.erase([card_id])
	
	var view_3d: CardView3D = card.get_view_3d(true)[0]
	#view_3d.card_show()
	view_3d.show()
	
	#card.card_show()
	
	# 注意，现在卡牌以及不在area节点下面了
	# 现在需要直接查询绑定表
	var scene = Utils.get_current_scene()
	if not is_instance_valid(scene):
		assert(false, "CardApi: set_area: scene is not valid")
	if scene is not Battle:
		assert(false, "CardApi: set_area: scene is not Battle")
	var battle: Battle = scene

	battle.battle_data_bind_list.clean_card(card_id, { "type": null })
	var heaps = battle.battle_data_bind_list.area_bind_cards
	heaps[area_id].append(card_id)
	
	var cards_in_area = FindUtils.find_condition_cards({
		"areas": [ area_id ]
	}).size()
	
	view_3d.global_position = area.get_position()
	# card.global_position.y = area.get_top_position().y + 0.001 + (ConfigManager.CARD_THICKNESS * (cards_in_area + 1))
	#card.global_position.y = area.get_top_position().y + 0.025 + (ConfigManager.CARD_THICKNESS * (cards_in_area + 1))
	view_3d.global_position.y = area.get_position().y + 0.04 + (ConfigManager.CARD_THICKNESS * (cards_in_area + 1))
	#card.card_info_show.update()
	#CoreCardSetApi.__update()



@rpc("any_peer", "call_local", "reliable")
func get_image(id: String) -> Dictionary:
	var res = {
		"front": "",
		"background": ""
	}
	if not id:
		return res
	var card = FindUtils.find_card(id)
	# res["front"] = card.entity.image
	res["front"] = card.image
	var battle: Battle = Utils.get_current_scene()
	for k in battle.battle_data_bind_list.player_bind_cards_of_ownership:
		if id in battle.battle_data_bind_list.player_bind_cards_of_ownership[k]:
			var player = FindUtils.find_player(k)
			res["background"] = player.use_card_back
	return res

func get_front(id: String) -> bool:
	if not id:
		return true
	var card = FindUtils.find_card(id)
	if card is not CardEntity:
		return true
	# return card.entity.is_front
	return card.is_front

func get_direction(id: String) -> Dictionary:
	var card = FindUtils.find_card(id)
	var views = card.get_view_3d()
	if views.is_empty():
		return {"x": 0, "y": 0}
	# y 0: x=-1,y=-1
	# y 90: x=1,y=-1
	# y -90: x=-1,y=1
	# y 180: x=1,y=1
	# FIXME: 一个潜在的BUG，这些值需要四舍五入，因为浮点数的精度问题，可能不会匹配上。需要四舍五入
	var view = views.front()
	var direction = Vector2(0, 0)
	# 0朝左方向，90朝下方向，-90朝上方向，180朝右方向
	# 这个修正是因为坐标从0，0开始，从左上角开始
	match int(view.global_rotation_degrees.y):
		0: direction = Vector2(-1, -1)
		90: direction = Vector2(1, 1)
		-90: direction = Vector2(-1, -1)
		180: direction = Vector2(1, 1)
	return {"x": direction.x, "y": direction.y}

func get_ownership(id: String) -> String:
	var battle: Battle = Utils.get_current_scene()
	for k in battle.battle_data_bind_list.player_bind_cards_of_ownership:
		if id in battle.battle_data_bind_list.player_bind_cards_of_ownership[k]:
			return k
	return ""

func get_controller(id: String) -> String:
	var battle: Battle = Utils.get_current_scene()
	for k in battle.battle_data_bind_list.player_bind_cards_of_controller:
		if id in battle.battle_data_bind_list.player_bind_cards_of_controller[k]:
			return k
	return ""

# FIXME TODO
# 这里修改，仅保留手牌作为特殊区域
# 卡组和墓地不再作为特殊区域
func get_area(id: String) -> Dictionary:
	var info = {
		"area_id": null,
		"player_id": null,
		"camp": null,
		"type": null
	}
	var battle: Battle = Utils.get_current_scene()
	# 查区域
	for k in battle.battle_data_bind_list.area_bind_cards:
		if id in battle.battle_data_bind_list.area_bind_cards[k]:
			info["area_id"] = k
			return info
	# 查卡堆
	for set_id in battle.battle_data_bind_list.card_set:
		for player_id in battle.battle_data_bind_list.card_set[set_id]["data"]:
			if id in battle.battle_data_bind_list.card_set[set_id]["data"][player_id]:
				info["player_id"] = player_id
				info["type"] = set_id
				return info
	return info

# 待修复
static func adjust_card_rotation(card: CardView3D) -> void:
	var _rotation := Vector3.ZERO
	# if card.entity.is_front:
	if card.entity.is_front:
		_rotation = Vector3.ZERO
	else:
		_rotation = Vector3(0, 0, 180)
	var battle: Battle = Utils.get_current_scene()
	var card_ownership = ""
	for key in battle.battle_data_bind_list.player_bind_cards_of_controller:
		if card.entity.name in battle.battle_data_bind_list.player_bind_cards_of_controller[key]:
			card_ownership = key
			break
	var _camp: String = ""
	var card_player = FindUtils.find_player(card_ownership)
	if card_player is not Player:
		return
	for key in battle.battle_data_bind_list.camp_bind_players:
		if card_player.name in battle.battle_data_bind_list.camp_bind_players[key]:
			_camp = key
			break
	# var camps = Utils.get_scene_tree().get_nodes_in_group(&"camp")
	var camps = Utils.get_current_scene().camps.values()
	for camp in camps:
		if camp.title == _camp:
			_rotation.y = camp.orientation.y * 90
			break
	if _camp == "RED":
		# if card.entity.is_orientation:
		if card.entity.is_orientation:
			_rotation = Vector3(_rotation.x, -180, _rotation.z)
		else:
			_rotation = Vector3.ZERO
	else:
		# if card.entity.is_orientation:
		if card.entity.is_orientation:
			_rotation = Vector3(_rotation.x, 0, _rotation.z)
		else:
			_rotation = Vector3(_rotation.x, 0, _rotation.z)
	card.global_rotation_degrees = _rotation
	#card.card_info_show.adjust_card_rotation()
