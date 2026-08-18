extends Object
class_name FindUtils


# FIXME: 获取敌人的ID
# static func get_enemy(player_id: StringName) -> StringName:
# 	var scene_tree = Utils.get_scene_tree()
# 	if not scene_tree:
# 		return ""
# 	if scene_tree as Battle:
# 		var battle = scene_tree as Battle
# 		battle.players["BLUE"].find_custom(func(player: Player): if (player.name == player_id): return true) \
# 		if battle.Players["RED"][0].name \
# 		else battle.Players["BLUE"][0].name
# 	return ""

# FIXME: 通过使用的设施和类别获取到对应的区域编码
# static func get_facility_type_area(facility: Player.UseFacility, type: Area.Type) -> Array[Area.State]:
# 	if (facility == Player.UseFacility.NONE): return []
# 	if (type == Area.Type.NONE): return []
# 	if (type == Area.Type.BATTLEFIELD_PUBLIC): return range(110, 115)
# 	if (facility == Player.UseFacility.BLUE):
# 		if (type == Area.Type.HAND): return [Area.State.HAND_BLUE]
# 		if (type == Area.Type.DECK): return [Area.State.DECK_BLUE]
# 		if (type == Area.Type.ABANDON): return [Area.State.ABANDON_BLUE]
# 		if (type == Area.Type.BATTLEFIELD_SELF): return range(100, 110)
# 	if (facility == Player.UseFacility.RED):
# 		if (type == Area.Type.HAND): return [Area.State.HAND_RED]
# 		if (type == Area.Type.DECK): return [Area.State.DECK_RED]
# 		if (type == Area.Type.ABANDON): return [Area.State.ABANDON_RED]
# 		if (type == Area.Type.BATTLEFIELD_SELF): return range(115, 125)
# 	return []

# FIXME: 获取灵客所用设施上的卡
# static func get_facility_on_card(owner: String, facility: Player.UseFacility, type: Area.Type) -> Array:
# 	if (facility == Player.UseFacility.NONE): return []
# 	if (type == Area.Type.NONE): return []
# 	if (type == Area.Type.BATTLEFIELD_PUBLIC):
# 		var result = []
# 		for i in range(110, 115):
# 			result.append_array(filter_cards(get_area_on_card(i as Area.State), {"owner": owner}))
# 		return result
# 	if (facility == Player.UseFacility.BLUE):
# 		if (type == Area.Type.HAND): return filter_cards(get_area_on_card(Area.State.HAND_BLUE), {"owner": owner})
# 		if (type == Area.Type.DECK): return filter_cards(get_area_on_card(Area.State.DECK_BLUE), {"owner": owner})
# 		if (type == Area.Type.ABANDON): return filter_cards(get_area_on_card(Area.State.ABANDON_BLUE), {"owner": owner})
# 		if (type == Area.Type.BATTLEFIELD_SELF):
# 			var result = []
# 			for i in range(100, 110):
# 				result.append_array(filter_cards(get_area_on_card(i as Area.State), {"owner": owner}))
# 			return result
# 	if (facility == Player.UseFacility.RED):
# 		if (type == Area.Type.HAND): return filter_cards(get_area_on_card(Area.State.HAND_RED), {"owner": owner})
# 		if (type == Area.Type.DECK): return filter_cards(get_area_on_card(Area.State.DECK_RED), {"owner": owner})
# 		if (type == Area.Type.ABANDON): return filter_cards(get_area_on_card(Area.State.ABANDON_RED), {"owner": owner})
# 		if (type == Area.Type.BATTLEFIELD_SELF):
# 			var result = []
# 			for i in range(115, 125):
# 				result.append_array(filter_cards(get_area_on_card(i as Area.State), {"owner": owner}))
# 			return result
# 	return []

static func filter_cards(cards: Array, condition: Dictionary) -> Array:
	return find_condition_cards(condition, cards)

## FIXME: 待修复
## 用于从指定的区域中获取所有卡
# static func get_area_on_card(area_id) -> Array:
# 	var area: AreaEntity = Utils.find_area(area_id as Area.State)
# 	var cards = area.heap.get_children()
# 	if cards.is_empty():
# 		return []
# 	return cards

static func _find_condition_entity_for_attr(keys: Dictionary, entity: Entity) -> bool:
	for key in keys:
		var cv = entity.get_attr_by_id(key)
		if cv == null:
			return false
		if cv != keys[key]:
			return false
	return true

static func find_condition_cards(condition: Dictionary, cards: Array = []) -> Array:
	# print("FIND_UTILS: find_condition_cards: ", condition, " | cards: ", cards)
	var result = []
	if cards.is_empty():
		# cards = Utils.get_scene_tree().get_nodes_in_group(&"card")
		cards = Utils.get_current_scene().cards.values()
		# print("FIND_UTILS: find_condition_cards: ", condition, " | cards: ", cards.size())
	var battle: Battle = Utils.get_current_scene()
	for card: CardEntity in cards:
		# 判断控制者
		if condition.has("owners"):
			var k = false
			for owner in condition["owners"]:
				if battle.battle_data_bind_list.player_bind_cards_of_controller.has(owner) and card.name in battle.battle_data_bind_list.player_bind_cards_of_controller[owner]:
					k = true
					break
			if not k: continue
		# 判断卡片类型（固有属性）
		if condition.has("kinds"):
			var k = false
			for owner in condition["kinds"]:
				if card.meta["type"] == owner:
					k = true
					break
			if not k: continue
		# 判断卡片所在区域（固有属性）
		if condition.has("areas"):
			var k = false
			for area in condition["areas"]:
				if battle.battle_data_bind_list.area_bind_cards.has(area) and card.name in battle.battle_data_bind_list.area_bind_cards[area]:
					k = true
					break
			if not k: continue
		# sets
		if condition.has("sets"):
			var k = false
			for _set in condition["sets"]:
				for pid in battle.battle_data_bind_list.card_set[_set]["data"]:
					if battle.battle_data_bind_list.card_set[_set]["data"].has(pid) and card.name in battle.battle_data_bind_list.card_set[_set]["data"][pid]:
						k = true
						break
				if k: break
			if not k: continue
		result.append(card)
	return result

static func find_condition_areas(condition: Dictionary, areas: Array = []) -> Array:
	var result = []
	if (areas.is_empty()):
		# areas = Utils.get_scene_tree().get_nodes_in_group(&"area")
		areas = Utils.get_current_scene().areas.values()
	var battle: Battle = Utils.get_current_scene()
	for area: AreaEntity in areas:
		if area.name.begins_with("AREA_INLAY_"):
			continue
		if condition.has("owners"):
			var k = false
			for owner in condition["owners"]:
				if owner in battle.battle_data_bind_list.area_bind_players[area.name]:
					k = true
					break
			if not k: continue
		if condition.has("positions"):
			var k = false
			for pos in condition["positions"]:
				if area.x == pos.x and area.y == pos.y:
					k = true
					break
			if not k: continue
		result.append(area)
	return result

static func find_card(id: StringName) -> CardEntity:
	return find_for_name(&"card", id)

static func find_area(id: StringName) -> AreaEntity:
	#return find_for_name(&"area", id)
	#var scene_tree = Utils.get_scene_tree()
	#if not scene_tree:
		#return null
	#var nodes = scene_tree.get_nodes_in_group(&"area")
	#for node in nodes:
		#if node.name == id:
			#return node
	#return null
	return find_for_name(&"area", id)

static func find_player(id: StringName) -> Player:
	return find_for_name(&"player", id)
	#var node = Utils.get_current_scene()
	#if node is Battle:
		#var battle: Battle = node
		#return battle.players[id]
	#return null

static func find_behavior(id: StringName) -> Behavior:
	return find_for_name(&"behavior", id)
	#return null
	# FIXME


static func find_entity(id: StringName) -> Entity:
	var scene_tree = Utils.get_current_scene()
	if scene_tree is not Battle:
		return null
	var nodes = []
	nodes.append_array(scene_tree.cards.values())
	nodes.append_array(scene_tree.players.values())
	nodes.append_array(scene_tree.areas.values())
	for node in nodes:
		if not node.meta["entity"]:
			continue
		if node.meta["entity"]["id"] == id:
			return node
	return null


static func find_for_name(group: StringName, name: StringName) -> Object:
	#var scene_tree = Utils.get_scene_tree()
	#if not scene_tree:
		#return null
	#var nodes = scene_tree.get_nodes_in_group(group)
	#for node in nodes:
		#if node.name == name:
			#return node
	#return null
	var node = Utils.get_current_scene()
	if node is Battle:
		var battle: Battle = node
		match group:
			&"player": return battle.players[name]
			&"card": return battle.cards[name]
			&"area": return battle.areas[name]
			&"behavior": return battle.behaviors[name]
	return null
