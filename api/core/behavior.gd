extends Node
class_name CoreBehaviorApi


func create(template: String) -> Behavior:
	# 根据模板，创建行为
	var behavior_template_file_path = GResourceManager.behavior_resource[template]
	if behavior_template_file_path.is_empty():
		assert(false, "CoreBehaviorApi: create: behavior_template_file_path is not valid")
	var meta = ModManager.state.do_file(behavior_template_file_path)
	if meta is LuaError:
		assert(false, "CoreBehaviorApi: create: meta is lua error: " + meta.message)
	if meta is not LuaFunction:
		assert(false, "CoreBehaviorApi: create: meta is not lua function")
	meta = meta.invoke()
	if meta is LuaError:
		assert(false, "CoreBehaviorApi: create: meta is lua error: " + meta.message)
	if meta is not LuaTable:
		assert(false, "CoreBehaviorApi: create: meta is not lua table")
	#var behavior_lua = load("res://core/behavior/behavior_lua.tscn").instantiate()
	var behavior_lua = BehaviorLua.new()
	var _behavior_id = ""
	if meta["id"]:
		_behavior_id = meta["id"]
	else:
			var _id = IDUtils.generate("BEHAVIOR_")
			meta["id"] = _id
			_behavior_id = _id
	# print(">> Behavior Create: ", _behavior_id)
	behavior_lua.init_data(meta)
	behavior_lua.name = _behavior_id
	behavior_lua.template = template
	return behavior_lua


func get_all(entity_id: String) -> Array:
	var scene: Battle = Utils.get_current_scene()
	var bs = scene.battle_data_bind_list.card_bind_behaviors.get(entity_id, [])

	var result = []
	for b in bs:
		var br = FindUtils.find_behavior(b)
		result.append(br.data)
	return result


# 仅 Card 挂有 behavior
func get_ownership(id: String) -> Variant:
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return null
	
	var battle: Battle = scene
	
	var card_id = ""
	for bkey in battle.battle_data_bind_list.card_bind_behaviors:
		if id in battle.battle_data_bind_list.card_bind_behaviors[bkey]:
			card_id = bkey
	if not card_id:
		return null
	
	var card = FindUtils.find_card(card_id)
	if not card:
		return null
	return card


@rpc("any_peer", "call_local", "reliable")
func append_entity(entity_id, template, unique) -> void:
	var entity: Entity = FindUtils.find_entity(entity_id)
	if not entity:
		return
	if unique:
		for b: Behavior in entity.behavior_manager.behaviors:
			if b.template == template:
				return
	var behavior: Behavior = create(template)
	if not behavior:
		return
	entity.behavior_manager.add_behavior(behavior)

	if entity_id.begins_with("CARD_"):
		var battle: Battle = Utils.get_current_scene()
		battle.battle_data_bind_list.card_bind_behaviors[entity_id].append(behavior.name)


@rpc("any_peer", "call_local", "reliable")
func remove_entity(entity_id, template) -> void:
	var entity: Entity = FindUtils.find_entity(entity_id)
	if not entity:
		return
	for b: Behavior in entity.behavior_manager.behaviors:
		if b.template == template:
			for _timepoint in Utils.get_current_scene().timepoint_manager.rr_meta:
				if _timepoint.entity == b:
					Utils.get_current_scene().timepoint_manager.rr_meta.erase(_timepoint)
					break
			if entity_id.begins_with("CARD_"):
				var battle: Battle = Utils.get_current_scene()
				battle.battle_data_bind_list.card_bind_behaviors[entity_id].erase(b.name)
			entity.behavior_manager.behaviors.erase(b)
			#b.queue_free()
	# var behavior: Behavior = create(template)
	# if not behavior:
	# 	return
	# entity.behavior_manager.add_behavior(behavior)
	# if entity_id.begins_with("CARD_"):
	# 	var battle: Battle = Utils.get_current_scene()
	# 	battle.battle_data_bind_list.card_bind_behaviors[entity_id].append(behavior.name)
