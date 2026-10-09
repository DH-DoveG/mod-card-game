extends Object
class_name ModBehaviorApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("append_entity", state.create_function(append_entity))
	table.set("remove_entity", state.create_function(remove_entity))
	table.set("get_all", state.create_function(get_all))
	table.set("get_can_launch_behaviors", state.create_function(get_can_launch_behaviors))
	table.set("get_behavior", state.create_function(get_behavior))

	# Chain-Triggers API
	table.set("set_chain_triggers_override", state.create_function(set_chain_triggers_override))
	table.set("add_chain_trigger", state.create_function(add_chain_trigger))
	table.set("remove_chain_trigger", state.create_function(remove_chain_trigger))
	table.set("clear_chain_triggers_overrides", state.create_function(clear_chain_triggers_overrides))
	table.set("get_resolved_chain_triggers", state.create_function(get_resolved_chain_triggers))

	# Chain 候选收集
	table.set("collect_chain_candidates", state.create_function(collect_chain_candidates))

	state.globals["package"]["loaded"]["std.api.behavior-api"] = table

static func get_behavior(param) -> LuaTable:
	var code = param["code"] if param["code"] != null else ""
	if code == "":
		return null
	var battle: Battle = Utils.get_current_scene()
	return battle.behaviors[code].data

static func get_can_launch_behaviors(param: LuaTable) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var id = param["entity_id"] if param["entity_id"] != null else ""
		var cl_arg = param["cl_arg"] if param["cl_arg"] != null else null
		if not id: return ModManager.state.create_table()
		var result = []
		var entity: Entity = null
		if id.begins_with("PLAYER_"):
			entity = FindUtils.find_player(id)
		elif id.begins_with("CARD_"):
			entity = FindUtils.find_card(id)
		elif id.begins_with("AREA_"):
			entity = FindUtils.find_area(id)
		else:
			return

		var bt := Behavior.BehaviorTrigger.new()
		bt.setup(entity.name, "", null)

		var scene: Battle = Utils.get_current_scene()
		for bcode in entity.behaviors:
			bt.code = bcode
			var b = scene.behaviors[bcode]
			bt.behavior_ref = b
			var cl = await b.check_launch(bt, cl_arg)
			if not cl: continue
			var cc = await b.check_cost(bt, cl_arg)
			if not cc: continue
			result.append(b.data)
		return LuaUtils.array_to_table(result)
	, param)

static func get_all(param: LuaTable) -> LuaTable:
	var entity_id = param["entity_id"] if param["entity_id"] != null else ""
	if not entity_id: return ModManager.state.create_table()
	var result = GApiManager.behavior_api.get_all(entity_id)
	return LuaUtils.array_to_table(result)

static func append_entity(_param: LuaTable) -> void:
	var entity_id = _param["entity_id"] if _param["entity_id"] != null else ""
	var template = _param["template"] if _param["template"] != null else ""
	var unique = _param["unique"] if _param["unique"] != null else false
	if not entity_id or not template:
		return
	GApiManager.behavior_api.rpc("append_entity", entity_id, template, unique)

static func remove_entity(_param: LuaTable) -> void:
	var entity_id = _param["entity_id"] if _param["entity_id"] != null else ""
	var template = _param["template"] if _param["template"] != null else ""
	if not entity_id or not template:
		return
	GApiManager.behavior_api.rpc("remove_entity", entity_id, template)

# ═══════════════════════════════════════════
# Chain-Triggers API
# ═══════════════════════════════════════════

static func _find_entity_by_id(id: String) -> Entity:
	if id.is_empty(): return null
	if id.begins_with("CARD_"):
		return FindUtils.find_card(id)
	elif id.begins_with("PLAYER_"):
		return FindUtils.find_player(id)
	elif id.begins_with("AREA_"):
		return FindUtils.find_area(id)
	elif id.begins_with("CAMP_"):
		return FindUtils.find_entity(id)
	return null

static func set_chain_triggers_override(param: LuaTable) -> void:
	var entity_id: String = param["entity_id"] if param["entity_id"] != null else ""
	var code: String = param["code"] if param["code"] != null else ""
	if not entity_id or not code: return
	if param["triggers"] == null: return
	var entity = _find_entity_by_id(entity_id)
	if entity == null: return
	var triggers = LuaUtils.table_to_array(param["triggers"])
	entity.set_behavior_state(code, "__chain_triggers_override", triggers)

static func add_chain_trigger(param: LuaTable) -> void:
	var entity_id: String = param["entity_id"] if param["entity_id"] != null else ""
	var code: String = param["code"] if param["code"] != null else ""
	var trigger_name: String = param["trigger"] if param["trigger"] != null else ""
	if not entity_id or not code or not trigger_name: return
	var entity = _find_entity_by_id(entity_id)
	if entity == null: return
	var state = entity.get_behavior_state(code)
	var add_list = state.get("__chain_triggers_add", [])
	if add_list is Array:
		if trigger_name not in add_list:
			add_list.append(trigger_name)
	else:
		add_list = [trigger_name]
	entity.set_behavior_state(code, "__chain_triggers_add", add_list)

static func remove_chain_trigger(param: LuaTable) -> void:
	var entity_id: String = param["entity_id"] if param["entity_id"] != null else ""
	var code: String = param["code"] if param["code"] != null else ""
	var trigger_name: String = param["trigger"] if param["trigger"] != null else ""
	if not entity_id or not code or not trigger_name: return
	var entity = _find_entity_by_id(entity_id)
	if entity == null: return
	var state = entity.get_behavior_state(code)
	var remove_list = state.get("__chain_triggers_remove", [])
	if remove_list is Array:
		if trigger_name not in remove_list:
			remove_list.append(trigger_name)
	else:
		remove_list = [trigger_name]
	entity.set_behavior_state(code, "__chain_triggers_remove", remove_list)

static func clear_chain_triggers_overrides(param: LuaTable) -> void:
	var entity_id: String = param["entity_id"] if param["entity_id"] != null else ""
	var code: String = param["code"] if param["code"] != null else ""
	if not entity_id or not code: return
	var entity = _find_entity_by_id(entity_id)
	if entity == null: return
	var state = entity.get_behavior_state(code)
	state.erase("__chain_triggers_override")
	state.erase("__chain_triggers_add")
	state.erase("__chain_triggers_remove")

static func get_resolved_chain_triggers(param: LuaTable) -> LuaTable:
	var entity_id: String = param["entity_id"] if param["entity_id"] != null else ""
	var code: String = param["code"] if param["code"] != null else ""
	if not entity_id or not code:
		return ModManager.state.create_table({})
	var entity = _find_entity_by_id(entity_id)
	if entity == null:
		return ModManager.state.create_table({})
	var behavior = FindUtils.find_behavior(code)
	var bt = Behavior.BehaviorTrigger.new()
	bt.setup(entity_id, code, behavior)
	var result = bt.get_resolved_chain_triggers()
	return LuaUtils.array_to_table(result)

# ═══════════════════════════════════════════
# Chain 候选收集（核心入口）
# ═══════════════════════════════════════════

static func collect_chain_candidates(param: LuaTable) -> Signal:
	# 收集所有可在当前事件下连锁的 BehaviorTrigger 候选列表
	# 内部遍历 battle 中全部 Entity，对每个 behavior：
	#  1) chain_triggers 快速过滤（事件名匹配）
	#  2) check_launch 精确检查
	#  3) check_cost 精确检查
	# 全部通过即加入候选列表。
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var event: LuaTable = param["event"]
		if event == null:
			return LuaUtils.array_to_table([])
		var event_name: String = event["header"]["name"] if event["header"] != null else ""
		if not event_name:
			return LuaUtils.array_to_table([])

		var battle: Battle = Utils.get_current_scene()
		if battle == null:
			return LuaUtils.array_to_table([])

		var result: Array[Dictionary] = []

		# 1. 收集所有有 behavior 的 Entity
		var entities: Array[Entity] = []

		for key in battle.cards:
			var e: Entity = battle.cards[key] as Entity
			if e != null and not e.behaviors.is_empty():
				entities.append(e)

		for key in battle.players:
			var e: Entity = battle.players[key] as Entity
			if e != null and not e.behaviors.is_empty():
				entities.append(e)

		for key in battle.areas:
			var e: Entity = battle.areas[key] as Entity
			if e != null and not e.behaviors.is_empty():
				entities.append(e)

		for key in battle.camps:
			var e: Entity = battle.camps[key] as Entity
			if e != null and not e.behaviors.is_empty():
				entities.append(e)

		# 2. 对每个 Entity 的每个 behavior 做过滤
		for entity in entities:
			for bcode in entity.behaviors:
				var behavior = battle.behaviors.get(bcode)
				if behavior == null:
					continue

				var bt = Behavior.BehaviorTrigger.new()
				bt.setup(entity.name, bcode, behavior)
				# bt.set_trigger("SYSTEM_CHAIN", { "event_name": event_name })

				# a) chain_triggers 快速过滤
				var triggers = bt.get_resolved_chain_triggers()
				if triggers.is_empty():
					continue
				var matched = false
				for t in triggers:
					if t == "*" or t == event_name:
						matched = true
						break
				if not matched:
					continue

				# b) check_launch
				var launch_args = { "event": event }
				if not await behavior.check_launch(bt, launch_args):
					continue

				# c) check_cost
				if not await behavior.check_cost(bt, launch_args):
					continue

				# 全部通过，加入候选
				result.append(bt.to_dict())

		return LuaUtils.array_to_table(result)
	, param)
