extends Status
class_name StatusLua

var data: LuaTable

func data_init(_init: Variant):
	data = _init

func hook_callback(_name: String, _arg: Variant):
	var fun: LuaFunction = data["hook_callback"]
	ModManager.run_lua_function(fun, LuaUtils.array_to_table([data, _name, ]), "ARRAY")

func start_callback(_entity_config):
	var fun: LuaFunction = data["start_callback"]
	ModManager.run_lua_function(fun, _entity_config)

func destroy_callback(_entity_config):
	var fun: LuaFunction = data["destroy_callback"]
	ModManager.run_lua_function(fun, _entity_config)
