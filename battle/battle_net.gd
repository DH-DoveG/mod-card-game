extends Battle


@onready var player_panel = $UI/PlayerPanel

var switch_visual_count = 0
const visual = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT]
var _play_meta_config = {}
var uid = 0
var player_count = 0

func _ready() -> void:
	randomize()
	round_num_changed.connect(func(new_value, _old_value):
		$UI/TopBar/RoundNum.text = "————<< 第 %d 回合 >>————" %new_value
	)
	event_manager.subscribe("VISUAL_ANGLE_CHANGED", set_angle_of_view)

# 客户端不用执行lua规则（这里指的是 start_rule）
# 因为 Entity 等都是GD实体，lua只是注册表
# 那么，需要考虑的只有那种调用交互时的询问
# 不过具体的还是要思考
#
# 有几种存在问题：
# 1. 对于素材选取有特定要求的带有验证函数的（特别是那种有 upvalue 的）
# 
# 以下几种有解决方案
# 1. game_api 的值是会同步的
# 2. behavior 的调用是不依赖上下文的
#
# 关于预感会出现，但是又无法具体的定位分析的问题，最好在遇到时再想办法解决

var _init_plase_finished = 0

# 这个用于等待其他玩家是否加载好
func await_answer(data):
	if data.data["type"] == "init_plase":
		if data.data["method"] == "_init_plase1":
			_init_plase_finished += 1
			rpc("set_loading_text", "正在初始化玩家信息（%d/%d）" % [_init_plase_finished, player_count])
			if _init_plase_finished == player_count:
				_init_plase_finished = 0
				rpc("_init_plase2", _play_meta_config)
		if data.data["method"] == "_init_plase2":
			_init_plase_finished += 1
			rpc("set_loading_text", "正在初始化游戏数据（%d/%d）" % [_init_plase_finished, player_count])
			if _init_plase_finished == player_count:
				_init_plase_finished = 0
				rpc("_init_plase3")
		if data.data["method"] == "_init_plase3":
			_init_plase_finished += 1
			if _init_plase_finished == player_count:
				_init_plase_finished = 0
				rpc("set_loading_text", "正在运行模组规则")
				get_tree().create_timer(1).timeout.connect(_exec_rule.bind(_play_meta_config), ConnectFlags.CONNECT_ONE_SHOT)


@rpc("any_peer", "call_local", "reliable")
func set_loading_text(text):
	$UI/LoadingPanel.set_loading_text(text)



func set_loading_page(show: bool):
	$UI/LoadingPanel.visible = show



## 这里应该接受玩家的设置
##	{
##		"localhost": {
##			"id": number,
##			"camp": "RED"|"BLUE"|"JOINUDIENCES"
##		},
##		"camp": {
##			# human的 id 是 number; robot 的 id 是 string;
##			"BLUE": [{}], # { "id": number|string, "ready": true, "template": "base_player", "deck": { 参考卡组的文件结构 }, "type": "human"|"robot" }
##			"RED": [{}]
##		},
##		"joinudiences": [{}],
##		"start_rule": "" # 规则名
##	}
func on_scene_loaded(_arg):
	set_loading_page(true)
	
	_play_meta_config = _arg[0]
	
	for key in _play_meta_config["camp"]:
		player_count += key["list"].size()
	player_count += _play_meta_config["joinudiences"].size()
	
	uid = _play_meta_config["localhost"]["id"]
	
	if uid == 1:
		Utils.get_current_scene().rpc_awaiter.add_message_listener(await_answer)
	else:
		await get_tree().create_timer(0.5).timeout
	
	## 初始化灵客（因为虽然已经获取了玩家的配置信息，但是还没有为玩家进行实例化）
	## 这里需要将各个阵营的玩家的配置都全部提取出来
	var _players = _init_player(_play_meta_config["camp"])
	
	if _play_meta_config["localhost"]["camp"] == "JOINUDIENCES": host_is_audience = true
	else: host_is_audience = false
	
	if host_is_audience: 
		$UI/PlayerHandView.hide()
		$UI/BottomBar/VisualAngleChangeBtn.show()
	
	Utils.get_current_scene().rpc_awaiter.send_msg(1, { "type": "init_plase", "method": "_init_plase1", "status": "finished", "uid": uid })
	
	for camp in _players:
		for player: Player in _players[camp]:
			if typeof(player.id) == TYPE_STRING and str(player.id).begins_with("R"):
				Utils.get_current_scene().rpc_awaiter.send_msg(1, { "type": "init_plase", "method": "_init_plase1", "status": "finished", "uid": player.id })


@rpc("any_peer", "call_local", "reliable")
func _init_plase2(arg):
	# 执行各个规则的准备
	_init_starter(arg)
	Utils.get_current_scene().rpc_awaiter.send_msg(1, { "type": "init_plase", "method": "_init_plase2", "status": "finished", "uid": uid })
	# 需要帮助Robot完成
	for player: Player in players.values():
		if typeof(player.id) == TYPE_STRING and str(player.id).begins_with("R"):
			Utils.get_current_scene().rpc_awaiter.send_msg(1, { "type": "init_plase", "method": "_init_plase2", "status": "finished", "uid": player.id })


@rpc("any_peer", "call_local", "reliable")
func _init_plase3():
	# 执行各个规则的准备
	if GNetManager.uid == 1:
		# 构建卡组
		# 这个应该由主机进行处理
		# rpc 的调用需要缓一缓，不然会爆炸（导致客户端断开连接）
		_init_deck(players)
		# 为所有动作添加事件绑定
		_bind_action_events()
		# 开始执行游戏的启动规则
	Utils.get_current_scene().rpc_awaiter.send_msg(1, { "type": "init_plase", "method": "_init_plase3", "status": "finished", "uid": uid })
	# 需要帮助Robot完成
	for player: Player in players.values(): # [camp]:
		if typeof(player.id) == TYPE_STRING and str(player.id).begins_with("R"):
			Utils.get_current_scene().rpc_awaiter.send_msg(1, { "type": "init_plase", "method": "_init_plase3", "status": "finished", "uid": player.id })


func _bind_action_events():
	var behavior_manager_list = get_tree().get_nodes_in_group(&"behaviors")
	for behaviors in behavior_manager_list:
		behaviors.bind_action_events()


# POINT: 进度断点
func _init_starter(arg: Dictionary):
	var param = arg.duplicate(true)
	## 处理完成后的 param 期望格式：
	## { players: {camp: string, list: Player[]}[], config: table }
	var _players = []
	for i in param["camp"]:
		for j in i.list:
			_players.append(j["pid"])
	param["players"] = _players
	param["type"] = "BATTLE"
	for command in ModManager.use_mods:
		ModStarterCommand.new().args({"path": command["starter"], "param": param }).execute()


# arg: 格式
# { 
# 	"localhost": { "id": "PLAYER_00000000", "camp": "BLUE" }, 
# 	"camp": { "BLUE": [
# 		["DoveTest", 
# 			{
# 				"TYPE": "HUMAN", 
# 				"avatar": "DEFAULT_AVATAR", 
# 				"standing_sign": "", "deck": "D:/dh/mod_card/mod_card_mods/coci/decks/default.lua", 
# 				"id": "PLAYER_00000000", 
# 				"name": "DoveTest"
# 			}
# 		], ...
# 	],
# 	"joinudiences": [],
# 	"start_rule": "Battle Start Rule"
# }
func _exec_rule(_arg: Dictionary):
	# 期待的数据格式： { players: {string : string[] }
	var param = { "players": [] }
	for key in _arg["camp"]:
		var _camps = []
		for array in key["list"]:
			_camps.append(array["pid"])
		param["players"].append({ "camp": key["camp"], "list": _camps })
	
	rpc("set_battle_to_component")
	
	Utils.get_current_scene().rule_manager.exec_rule(_arg["start_rule"], LuaUtils.dictionary_to_table(param))


@rpc("call_local", "any_peer")
func set_battle_to_component():
	$UI/CardSetInfoPanel.set_battle(self)
	$UI/PlayerHandView.set_battle(self)
	$UI/CardInfoPanel.battle = self
	$UI/AreaInfoPanel.battle = self


## 这里做分解动作，首先这里只将玩家进行实例化
func _init_player(_camps):
	var result = {}
	for key in _camps:
		var list = key.list
		var cbp: PackedStringArray = []
		var p = []
		
		for item in list:
			var node: Player = GApiManager.player_api.create(item["pid"], item, get_path(), key["camp"])
			if typeof(item["uid"]) != TYPE_STRING or not item["uid"].begins_with("R"):
				node.use_card_back = GNetManager.players[item["uid"]]["card_back"]
			if str(item["uid"]) == str(uid):
				host_player_id = item["pid"]
				host_player = node
			cbp.append(item["pid"])
			p.append(node)
			player_panel.add_player(node)
			battle_data_bind_list.card_public_information[item["pid"]] = []
			
			players[item["pid"]] = node
			
		result[key["camp"]] = p
		battle_data_bind_list.camp_bind_players[key["camp"]] = cbp
	return result


func _init_deck(_players: Dictionary) -> void:
	for item: Player in _players.values():
		var param = {
			"deck": item.use_deck_config,
			"type": "BATTLE_DISPOSE_DECK"
		}
		var use_cards = []
		for command in ModManager.use_mods:
			var _v = ModStarterCommand.new()
			_v._args = {
				"path": command["starter"],
				"param": param
			}
			var _v_res = _v.execute()
			if _v_res:
				use_cards = _v_res.to_array()
		
		var card_count = 0
		for template in use_cards:
			var card_id = IDUtils.generate("CARD_")
			
			GApiManager.card_api.rpc("create_battle", card_id, template, item.name)
			
			card_count += 1
			rpc("set_loading_text", "正在初始化[%s]的卡组（%d/%d）" % [item.player_name, card_count, cards.size()])
		card_count = 0


func set_angle_of_view(angle) -> void:
	visual_angle = angle
	match visual_angle:
		Vector2i.DOWN:
			switch_visual_count = 0
		Vector2i.LEFT:
			switch_visual_count = 1
		Vector2i.UP:
			switch_visual_count = 2
		Vector2i.RIGHT:
			switch_visual_count = 3


func _on_round_end_btn_pressed() -> void:
	var btn = $UI/BottomBar/RoundEndBtn
	# 判断当前行动的是否是主机玩家
	if host_player_id != current_round_player:
		return
	if in_option:
		return
	btn.disabled = true
	var player = FindUtils.find_player(host_player_id)
	player.end_round()
	# 这里应该获取到数据判断当前的阶段状态
	get_tree().create_timer(0.5).timeout.connect(func():
		btn.disabled = false
	, ConnectFlags.CONNECT_ONE_SHOT)


func _on_area_info_show_btn_pressed() -> void:
	$UI/AreaInfoPanel.visible = not $UI/AreaInfoPanel.visible
	if $UI/AreaInfoPanel.visible: $UI/BottomBar/AreaInfoShowBtn.modulate = Color("FFF")
	else: $UI/BottomBar/AreaInfoShowBtn.modulate = Color("C8C8C8")


func _on_card_info_show_btn_pressed() -> void:
	$UI/CardInfoPanel.visible = not $UI/CardInfoPanel.visible
	if $UI/CardInfoPanel.visible: $UI/BottomBar/CardInfoShowBtn.modulate = Color("FFF")
	else: $UI/BottomBar/CardInfoShowBtn.modulate = Color("C8C8C8")


func _on_card_set_info_show_btn_pressed() -> void:
	$UI/CardSetInfoPanel.visible = not $UI/CardSetInfoPanel.visible
	if $UI/CardSetInfoPanel.visible: $UI/BottomBar/CardSetInfoShowBtn.modulate = Color("FFF")
	else: $UI/BottomBar/CardSetInfoShowBtn.modulate = Color("C8C8C8")


func _on_visual_angle_change_btn_pressed() -> void:
	var svc = switch_visual_count + 1
	event_manager.emit("VISUAL_ANGLE_CHANGED", visual[svc % 4])


func _on_log_show_btn_pressed() -> void:
	$UI/LogPanel.visible = not $UI/LogPanel.visible
	if $UI/LogPanel.visible: $UI/BottomBar/LogShowBtn.modulate = Color("FFF")
	else: $UI/BottomBar/LogShowBtn.modulate = Color("C8C8C8")
