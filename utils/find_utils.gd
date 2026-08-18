extends Object
class_name FindUtils

static func filter_cards(cards: Array, condition: Dictionary) -> Array:
	return find_condition_cards(condition, cards)

static func _find_condition_entity_for_attr(keys: Dictionary, entity: Entity) -> bool:
	for key in keys:
		var cv = entity.get_attr_by_id(key)
		if cv == null:
			return false
		if cv != keys[key]:
			return false
	return true

static func find_condition_cards(condition: Dictionary, cards: Array = []) -> Array:
	var result = []
	if cards.is_empty():
		cards = Utils.get_current_scene().cards.values()
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
	return find_for_name(&"area", id)

static func find_player(id: StringName) -> Player:
	return find_for_name(&"player", id)

static func find_behavior(id: StringName) -> Behavior:
	return find_for_name(&"behavior", id)

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
	var node = Utils.get_current_scene()
	if node is Battle:
		var battle: Battle = node
		match group:
			&"player": return battle.players[name]
			&"card": return battle.cards[name]
			&"area": return battle.areas[name]
			&"behavior": return battle.behaviors[name]
	return null
