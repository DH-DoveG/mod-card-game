extends Object
class_name ModBehaviorApi

static func require(state: LuaState) -> void:
	var table = state.create_table()

	table.set("append_entity", state.create_function(append_entity))
	table.set("remove_entity", state.create_function(remove_entity))
	table.set("get_all", state.create_function(get_all))
	table.set("get_can_launch_behaviors", state.create_function(get_can_launch_behaviors))
	state.globals["package"]["loaded"]["std.api.behavior-api"] = table

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
		bt.origin = entity.name

		var scene: Battle = Utils.get_current_scene()
		for bcode in entity.behaviors:
			bt.code = bcode
			var b = scene.behaviors[bcode]
			var cl = await b.check_launch(bt, cl_arg)
			if not cl: continue
			var cc = await b.check_cost()
			if not cc: continue
			result.append(b.data)
		return LuaUtils.array_to_table(result)
	, param)

static func get_all(param: LuaTable) -> LuaTable:
	var entity_id = param["entity_id"] if param["entity_id"] != null else ""
	if not entity_id: return ModManager.state.create_table()
	var result = GApiManager.behavior_api.get_all(entity_id)
	return LuaUtils.array_to_table(result)

	##return ownership.entity.meta

# FIXME: 这里增加 behavior 需要使用 路径参数
# 否则无法同步给其它端的玩家
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
