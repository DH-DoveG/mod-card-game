extends Object
class_name ModRuleApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("execute", state.create_function(execute))
	table.set("append", state.create_function(append))
	state.globals["package"]["loaded"]["std.api.rule-api"] = table

static func execute(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var res = await Utils.get_current_scene().rule_manager.exec_rule(_arg["name"], _arg["param"])
		if _arg["callback"]:
			_arg["callback"].invoke(res)
		return res
	, param)

## param.rule 规则对象 LuaTable
static func append(param) -> void:
	var _name = param["name"] if param["name"] != null else ""
	if _name.is_empty():
		return
	var rule_entry = load("res://core/rule/rule_entry_lua.gd").new()
	rule_entry.rule = param["rule"].invoke()
	# print("RULE APPEND|", _name, "|", rule_entry)
	Utils.get_current_scene().rule_manager.add_rule(rule_entry, _name)
