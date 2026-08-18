extends Object
class_name ModCardSetApi


static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("create", state.create_function(create))
	table.set("append", state.create_function(append))
	table.set("reset", state.create_function(reset))
	table.set("list", state.create_function(list))
	table.set("find_card", state.create_function(find_card))
	state.globals["package"]["loaded"]["std.api.card-set-api"] = table


static func create(param: LuaTable) -> void:
	var card_set_id = param["id"] if param["id"] != null else null
	var config = LuaUtils.table_to_dictionary(param["config"]) if param["config"] != null else {}
	if not card_set_id:
		return
	GApiManager.card_set_api.rpc("create", card_set_id, config)


static func find_card(param: LuaTable) -> LuaTable:
	var card_id = param["cid"] if param["cid"] != null else null
	if not card_id:
		return
	var res = GApiManager.card_set_api.find_card(card_id)
	if res == null:
		return res
	return LuaUtils.dictionary_to_table(res)


static func append(param: LuaTable) -> void:
	var card_set_id = param["id"] if param["id"] != null else null
	var pid = param["pid"] if param["pid"] != null else null
	var cards = param["cards"] if param["cards"] != null else null
	cards = LuaUtils.table_to_dictionary(cards).values()
	print("[MOD] card_set append > csi: ", card_set_id, " | pid: ", pid, " | cards: ", cards)
	if not card_set_id or not pid or not cards:
		return
	GApiManager.card_set_api.rpc("append", card_set_id, pid, cards)


static func reset(param: LuaTable) -> void:
	var card_set_id = param["id"] if param["id"] != null else null
	var pid = param["pid"] if param["pid"] != null else null
	var cards = param["cards"] if param["cards"] != null else null
	cards = LuaUtils.table_to_dictionary(cards).values()
	if not card_set_id or not pid or not cards:
		return
	GApiManager.card_set_api.rpc("reset", card_set_id, pid, cards)


static func list(param: LuaTable) -> Variant:
	var card_set_id = param["id"] if param["id"] != null else null
	var pid = param["pid"] if param["pid"] != null else null
	if not card_set_id:
		return
	var cards = GApiManager.card_set_api.list(card_set_id, pid)
	if typeof(cards) == TYPE_DICTIONARY:
		return LuaUtils.dictionary_to_table(cards)
	else:
		return LuaUtils.array_to_table(cards)
