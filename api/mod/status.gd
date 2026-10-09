extends Object
class_name ModStatusApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	state.globals["package"]["loaded"]["std.api.status-api"] = table