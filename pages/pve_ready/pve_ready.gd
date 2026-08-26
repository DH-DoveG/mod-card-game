extends Page

@onready var temp_player_item = $Templates/PlayerItem

@onready var info_side_user_avatar = $HBox/InfoSide/VBox/CR/HBox/Avatar
@onready var info_side_user_name = $HBox/InfoSide/VBox/CR/HBox/VBox/UserName
@onready var info_side_identity = $HBox/InfoSide/VBox/Identity/Label

@onready var list_player_queue = $HBox/List/PlayerQueue/Scroll/List
@onready var list_btn_joinudience = $HBox/List/Btns/ToJoinudience
@onready var list_btn_add_robot = $HBox/List/Btns/AddRobot
@onready var list_btn_add_player = $HBox/List/Btns/AddPlayer
@onready var list_choose_camp = $HBox/List/Btns/Camp/Option

@onready var option_side_player_template = $HBox/OptionSide/PlayerTemplate/Option
@onready var option_side_used_deck = $HBox/OptionSide/UsedDeck/Option
@onready var option_side_rule_entrance = $HBox/OptionSide/RuleEntrance/Option
@onready var option_side_btn_start_game = $HBox/OptionSide/Btns/StartGame
@onready var option_side_btn_ready = $HBox/OptionSide/Btns/Ready

@onready var chat_component = $HBox/InfoSide/VBox/Chat

var deck_tool = ""
var use_deck = ""
var camp = "JOINUDIENCES":
	set(v):
		camp = v
		match camp:
			"JOINUDIENCES":
				info_side_identity.text = "当前在观战席"
				option_side_btn_ready.disabled = true
			_:
				info_side_identity.text = "当前在【" + camp + "】阵营中"
				option_side_btn_ready.disabled = false

#class CampListPlayerConfig:
	#var uid = ""
	#var ready = false
	#var config = {}
#class CampListConfig:
	#var camp = ""
	#var list: Array = [] # Array[CampListPlayerConfig]
	#var max_count = 1
	#var min_count = 1
var camp_list = [] # Array[CampListConfig]
var can_choose_camps = []
var joinudiences = []


@rpc("any_peer", "call_local", "reliable")
func begin_game() -> void:
	var start_rule = ""
	if GNetManager.uid == 1:
		start_rule = option_side_rule_entrance.get_item_text(option_side_rule_entrance.get_selected_id())
	# 先转换
	
	for cl in camp_list:
		for l in cl.list:
			l["pid"] = IDUtils.generate("PLAYER_", str(l.uid), 0)
	
	var data = {
		"localhost": {
			"id": GNetManager.uid,
			"camp": camp # 如果阵营为 "" 表示主机玩家在观战席
		},
		"camp": camp_list,
		"joinudiences": joinudiences,
		"start_rule": start_rule
	}
	
	AsyncScene.new(
		"res://battle/battle_net.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters(data) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("4a2724ff")) \
	.start()

@rpc("any_peer", "call_local", "reliable")
func to_joinudience(id) -> void:
	if typeof(id) == TYPE_STRING and id.begins_with("R"):
		remove_player_for_joinudience_and_camp(id)
		reload_player_queue()
		return
	if id == GNetManager.uid:
		info_side_identity.text = "当前在【观众席】"
	remove_player_for_joinudience_and_camp(id)
	joinudiences.append({
		"id": id,
		"nick": GNetManager.players[id].nick,
		"avatar": GNetManager.players[id].avatar
	})
	chat_component.add_local_message("【提示】：玩家<" + GNetManager.players[id].nick + ">已加入观众席。")
	chat_component.add_local_message("【提示】：当前观众席人数（<" + str(joinudiences.size()) + ">）。")
	reload_player_queue()


@rpc("any_peer", "call_local", "reliable")
func to_camp(id, _camp: String, config: Dictionary) -> void:
	remove_player_for_joinudience_and_camp(id)
	for cl in camp_list:
		if cl.camp == _camp:
			var cpc = {
				"uid": id,
				"config": config,
				"ready": false,
				"template": "",
				"deck": "",
				"agent": ""
			}
			cl.list.append(cpc)
			break
	reload_player_queue()


func remove_player_for_joinudience_and_camp(id):
	for cl in camp_list:
		cl.list = cl.list.filter(func(i):
			return str(id) != str(i.uid)
		)
	joinudiences = joinudiences.filter(func(i):
		return str(id) != str(i.id)
	)


func reload_player_queue():
	for lpq in list_player_queue.get_children():
		lpq.queue_free()
	for cl in camp_list:
		for l in cl.list:
			var dup = temp_player_item.duplicate()
			dup.name = "ITEM_" + str(l.uid)
			list_player_queue.add_child(dup)
			dup.get_node("./HBox/HBox/Nick").text = l.config["nick"]
			dup.get_node("./HBox/HBox/Camp").text = cl.camp
			dup.get_node("./HBox/Avatar").texture = GResourceManager.get_image_resoure(l.config["avatar"])
			dup.get_node("./HBox/Panel/Ready").visible = l.ready
			
			# 如果 GNet.id 是 1 那么就拥有移除这些玩家的权力（除了自己）
			if GNetManager.uid == 1:
				if not (typeof(l.uid) == TYPE_INT and GNetManager.uid == l.uid):
					dup.get_node("./HBox/Remove").show()
					dup.get_node("./HBox/Remove").pressed.connect(func():
						rpc("to_joinudience", l.uid)
					)
			
			dup.show()
			


@rpc("any_peer", "call_local", "reliable")
func add_robot(id, _name, _camp) -> void:
	var f = GResourceManager.player_resource[_name]
	var _table = ModManager.do_mod_file(f.path).invoke()
	for cl in camp_list:
		if cl.camp == _camp:
			var cpc = {
				"uid": id,
				"config": {
					"nick": _table.name,
					"avatar": _table.avatar,
					"card_back": _table.card_back
				},
				"ready": true,
				"template": _name,
				"deck": _table.deck,
				"agent": _table.agent
			}
			cl.list.append(cpc)
			break
	reload_player_queue()


func pop_robot_dialog():
	var show_list = []
	for key in GResourceManager.player_resource:
		var value = GResourceManager.player_resource[key]
		show_list.append({
			"value": key,
			"background": value.standing_sign,
			"text": key
		})
	var _camp = list_choose_camp.get_item_text(list_choose_camp.get_selected_id())
	DialogUtils.show_select_item_dialog({
		"title": "请选择要添加的人机",
		"detail": "选择一个人机加入【" + _camp + "】阵营。",
		"list": {
			"items": show_list,
			"max": 1,
			"min": 1,
		},
		"btns": [
			{"text": "确定", "callback":
				func(chooses):
					if chooses.size() == 0:
						return {
							"close": false,
							"option": false
						}
					var _n = "R" + str(randi() % 255)
					rpc("add_robot", _n, chooses[0], _camp)
					return {
						"close": true,
						"option": false
					}},
			{"text": "取消", "callback": func(__): 
				return {
						"close": true,
						"option": false
				}},
		]
	})


@rpc("any_peer", "call_local", "reliable")
func player_ready_change(id, deck, template, agent) -> void:
	for cl in camp_list:
		for l in cl.list:
			if str(l.uid) == str(id):
				l.ready = !l.ready
				l.template = template
				l.deck = deck
				l.agent = agent
	reload_player_queue()


# 检查 Red 和 Blue 列表里的所有人是不是都已经准备完毕了
func check_player_ready() -> bool:
	for i in camp_list:
		if i.list.size() < i.min_count:
			chat_component.emit_message("【" + i.camp + "】阵营的人数少于要求的最低人数（" + str(i.min_count) + "）。当前该阵营人数：" + str(i.list.size()))
			return false
		if i.list.size() > i.max_count:
			chat_component.emit_message("【" + i.camp + "】阵营的人数多于要求的最高人数（" + str(i.max_count) + "）。当前该阵营人数：" + str(i.list.size()))
			return false
		for l in i["list"]:
			if l["ready"] == false:
				chat_component.emit_message("有人还没有准备！")
				return false
	return true


@rpc("any_peer", "call_local", "reliable")
func reload_camp_option(arr = null, deck_check_tool = null):
	chat_component.add_local_message("游戏规则已切换，可选阵营已更改")
	chat_component.add_local_message("游戏规则已切换，卡组检查规则已更改")
	deck_tool = deck_check_tool
	list_choose_camp.clear()
	camp_list.clear()
	if arr != null:
		can_choose_camps = arr
	for k in can_choose_camps:
		list_choose_camp.add_item(k["name"])
		var clc = {
			"camp": k["name"],
			"max_count": k["max"],
			"min_count": k["min"],
			"list": []
		}
		camp_list.append(clc)
	reload_player_queue()


@rpc("any_peer", "call_local", "reliable")
func set_rule_option(index: int):
	# 这里切换时调用
	var param = {
		"type": "SWITCH_START_BATTLE_RULE",
		"rule": option_side_rule_entrance.get_item_text(index)
	}
	for command in ModManager.use_mods:
		var tab = ModStarterCommand.new().args({
			"path": command["starter"],
			"param": param
		}).execute()
		if tab is LuaTable:
			if tab["camps"] == null: continue
			var arr = LuaUtils.table_to_dictionary(tab["camps"]).values()
			var deck_check_tool = tab["deck_tool"]
			rpc("reload_camp_option", arr, deck_check_tool)


@rpc("any_peer", "call_remote", "reliable")
func sync_data() -> Dictionary:
	return {
		"joinudiences": joinudiences,
		"camp_list": camp_list,
		"can_choose_camps": can_choose_camps
	}


func _init() -> void:
	page_id = "PVP_READY_PAGE"


func _ready() -> void:
	super ()

	ModManager.state.step_gc()
	
	GNetManager.game_status = GNetManager.GameStatus.ROOM
	
	# 玩家列表需要遍历放到观战席里
	# 连接信号
	GNetManager.add_player.connect(func(id):
		chat_component.add_local_message("欢迎玩家：【" + GNetManager.players[id].nick + "】！")
	)
	GNetManager.remove_player.connect(func(id):
		chat_component.add_local_message("玩家：【" + GNetManager.players[id].nick + "】已离开！")
		remove_player_for_joinudience_and_camp(id)
		reload_player_queue()
	)
	
	info_side_user_avatar.texture = GResourceManager.get_image_resoure(GNetManager.player_info.avatar)
	info_side_user_name.text = GNetManager.player_info.nick
	
	# FIXME: 这里需要对卡组进行检查吗？
	# 这里应该对卡组进行过滤，由 mod 指定一个规定的 检查工具
	# 或者说在准备时检查（最好是准备时检查）
	var files = PersistenceUtils.folder_all_files(ConfigManager.DECK_FOLDER_PATH)
	files = files.filter(func(_v): return _v.ends_with(".json"))
	for key in files:
		option_side_used_deck.add_item(key)
	for key in GResourceManager.deck_resource:
		option_side_used_deck.add_item(key)
	
	for key in GResourceManager.player_entitys_resource:
		option_side_player_template.add_item(key)
	
	if GNetManager.uid == 1:
		for key in GResourceManager.start_rule_resource:
			option_side_rule_entrance.add_item(key)
		rpc("set_rule_option", 0)
	else:
		# 只有主机玩家允许添加AI以及开始游戏
		option_side_btn_start_game.hide()
		list_btn_add_robot.hide()
		$HBox/OptionSide/RuleEntrance.hide()
	## 同步数据
	if GNetManager.uid != 1:
		var _res = await Utils.get_current_scene().rpc_awaiter.send_rpc_timeout(240, 1, sync_data)
		can_choose_camps = _res["can_choose_camps"]
		reload_camp_option()
		joinudiences = _res["joinudiences"]
		camp_list = _res["camp_list"]
		await get_tree().create_timer(0.25).timeout
		reload_player_queue()
		rpc("to_joinudience", GNetManager.uid)
	else:
		rpc("to_joinudience", GNetManager.uid)


func on_scene_loaded(_arg):
	# FIXME: 这里会释放 game_api 但是其他的不会释放，而且没有任何地方写了 game_api 的释放
	# print("\nGAME API4: ", GApiManager.game_api, "\n")
	# print("PR: ", _arg)
	pass


func _on_add_robot_pressed() -> void:
	pop_robot_dialog()


func _on_add_player_pressed() -> void:
	var _camp = list_choose_camp.get_item_text(list_choose_camp.get_selected_id())
	camp = _camp
	rpc("to_camp", GNetManager.uid, _camp, GNetManager.player_info)


func _on_ready_pressed() -> void:
	var template = option_side_player_template.get_item_text(option_side_player_template.get_selected_id())
	var f = GResourceManager.player_entitys_resource[template]
	var _table = ModManager.do_mod_file(f).invoke()
	var agent = _table.agent
	
	var deck = option_side_used_deck.get_item_text(option_side_used_deck.get_selected_id())
	var deck_file = GResourceManager.deck_resource.get(deck)
	var deck_config = {}
	if deck_file:
		var deck_table = ModManager.state.do_file(deck_file)
		deck_config = LuaUtils.table_to_dictionary(deck_table)
		deck_config["stack"] = deck_config["stack"].values()
		for c in deck_config["stack"]:
			c["content"] = c["content"].values()
	else:
		var file = PersistenceUtils.open_file(ConfigManager.DECK_FOLDER_PATH.path_join(deck))
		deck_config = JSON.parse_string(file.get_as_text())
	
	# 卡组检查
	if deck_tool:
		var fun = ModManager.do_mod_file(GResourceManager.deck_check_tool_resource[deck_tool])
		var table = LuaUtils.dictionary_to_table(deck_config)
		var result = fun.invoke(table)
		var r = LuaUtils.table_to_dictionary(result).values()
		for vv in r:
			var text = "卡堆：" + vv["stack"] + " | 信息：" + vv["message"]
			if not vv["result"]:
				ToastUtils.error(text)
				return
	
	rpc("player_ready_change", GNetManager.uid, deck_config, template, agent)


func _on_to_joinudience_pressed() -> void:
	camp = "JOINUDIENCES"
	rpc("to_joinudience", GNetManager.uid)


func _on_rule_option_item_selected(_index: int) -> void:
	rpc("set_rule_option", _index)


func _on_start_game_pressed() -> void:
	if not check_player_ready(): return
	rpc("begin_game")


func _on_close_page_btn_pressed() -> void:
	GNetManager.close()
