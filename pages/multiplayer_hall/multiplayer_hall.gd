extends Page


var edit_index = -1
var add_config_avatar: String = "DEFAULT_AVATAR"
var add_config_card_back: String = "DEFAULT_CARD_BACK"


func _init() -> void:
	page_id = "MULTIPLAYER_HALL_PAGE"

func _ready() -> void:
	super()
	reload_config()
	$AddConfig/Panel/Avatar.texture_normal = GResourceManager.get_image_resoure(add_config_avatar)
	$AddConfig/Panel/CardBack.texture_normal = GResourceManager.get_image_resoure(add_config_card_back)


#func _on_host_pressed() -> void:
	#GNetManager.be_host({
		#"nick": nick,
		#"avatar": avatar,
		#"card_back": card_back
	#})
	#to_pvp_ready_page()
#func _on_client_pressed() -> void:
	#$Mask.show()
	#$MaskTimer.start()
	#GNetManager.be_client({
		#"nick": nick,
		#"avatar": avatar,
		#"card_back": card_back
	#})
	#multiplayer.connected_to_server.connect(func():
		#$Mask.hide()
		#$MaskTimer.stop()
		#to_pvp_ready_page()
	#, ConnectFlags.CONNECT_ONE_SHOT)
	#
	#multiplayer.connection_failed.connect(func():
		#$Mask.hide()
		#$MaskTimer.stop()
		#ToastUtils.error("连接主机失败")
	#, ConnectFlags.CONNECT_ONE_SHOT)

func _on_avatar_pressed() -> void:
	var config = make_dialog_config("选择头像", "请从列表中选择一个作为头像", [ "AVATAR" ])
	var dialog = DialogUtils.show_select_image_dialog(config)
	var _res = await dialog.select_clicked
	if _res["choose_text"] == "Confirm":
		$AddConfig/Panel/Avatar.texture_normal = _res["choose_list"][0].resource
		add_config_avatar = _res["choose_list"][0].id
	dialog.queue_free()
func _on_card_back_pressed() -> void:
	var config = make_dialog_config("选择卡背", "请从列表中选择一个作为卡背", [ "CARD_BACK" ])
	var dialog = DialogUtils.show_select_image_dialog(config)
	var _res = await dialog.select_clicked
	if _res["choose_text"] == "Confirm":
		$AddConfig/Panel/CardBack.texture_normal = _res["choose_list"][0].resource
		add_config_card_back = _res["choose_list"][0].id
	dialog.queue_free()


func _on_mask_timer_timeout() -> void:
	if $ConnectMask/Label.text.length() < 8:
		$ConnectMask/Label.text += "."
	else:
		$ConnectMask/Label.text = "尝试连接中"


func _on_close_connect_pressed() -> void:
	GNetManager.close()
	$ConnectMask.hide()
	$MaskTimer.stop()


func _on_add_config_pressed() -> void:
	var title = $AddConfig/Panel/Edit/Title/LineEdit.text
	var nick = $AddConfig/Panel/Edit/Nick/LineEdit.text
	var address = $AddConfig/Panel/Edit/Address/LineEdit.text
	var port = $AddConfig/Panel/Edit/Port/LineEdit.text
	var detail = $AddConfig/Panel/Edit/Detail/TextEdit.text
	
	if edit_index == -1:
		ConfigManager.multiplayer_config.append({
			"title": title,
			"nick": nick,
			"address": address,
			"port": port,
			"avatar": add_config_avatar,
			"card_back": add_config_card_back,
			"detail": detail,
		})
	else:
		ConfigManager.multiplayer_config[edit_index] = {
			"title": title,
			"nick": nick,
			"address": address,
			"port": port,
			"avatar": add_config_avatar,
			"card_back": add_config_card_back,
			"detail": detail,
		}
		edit_index = -1
	
	var data = JSON.stringify(ConfigManager.multiplayer_config)
	var file = PersistenceUtils.open_file(ConfigManager.MULTIPLAYER_CONFIG_FILE_PATH)
	file.resize(data.length())
	file.store_string(data)
	
	reload_config()


func _on_close_config_pressed() -> void:
	$AddConfig.hide()


func _on_open_config_panel_pressed() -> void:
	$AddConfig.show()


func reload_config() -> void:
	var psv = $Panel/Scroll/VBox
	for node in psv.get_children():
		node.queue_free()
	var index = 0
	for config in ConfigManager.multiplayer_config:
		var dup = $Templates/ItemPanel.duplicate(true)
		dup.get_node("Title").text = config["title"]
		dup.get_node("VBox/Address").text = "地址：" + config["address"]
		dup.get_node("VBox/Port").text = "端口：" + config["port"]
		dup.get_node("VBox/Name").text = "昵称：" + config["nick"]
		dup.get_node("Detail").append_text(config["detail"])
		dup.get_node("CardBack").texture = GResourceManager.get_image_resoure(config["card_back"])
		dup.get_node("Avatar").texture = GResourceManager.get_image_resoure(config["avatar"])
		dup.get_node("Btns/SC/BeServer").pressed.connect(func():
			var finish = await GNetManager.be_connect("Server", {
				"nick": config["nick"],
				"avatar": config["avatar"],
				"card_back": config["card_back"]
			}, int(config["port"]), config["address"])
			#if not finish:
				#$ConnectMask.show()
				#$MaskTimer.start()
				#await GNetManager.be_finished
			if not finish: return
			AsyncScene.new(
				"res://pages/pvp_ready/pvp_ready.tscn",
				AsyncScene.LoadingOperation.ReplaceImmediate,
				self
			) \
			.with_parameters({}) \
			.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
			.start()
		)
		dup.get_node("Btns/SC/BeClient").pressed.connect(func():
			var finish = await GNetManager.be_connect("Client", {
				"nick": config["nick"],
				"avatar": config["avatar"],
				"card_back": config["card_back"]
			}, int(config["port"]), config["address"])
			#if not finish:
				#$ConnectMask.show()
				#$MaskTimer.start()
				#await GNetManager.be_finished
			if not finish: return
			AsyncScene.new(
				"res://pages/pvp_ready/pvp_ready.tscn",
				AsyncScene.LoadingOperation.ReplaceImmediate,
				self
			) \
			.with_parameters({}) \
			.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
			.start()
		)
		dup.get_node("Btns/HBox/Edit").pressed.connect(func():
			edit(index, config)
		)
		dup.get_node("Btns/HBox/Remove").pressed.connect(func():
			ConfigManager.multiplayer_config.remove_at(index)
			reload_config()
		)
		psv.add_child(dup)
		dup.show()
		index += 1


func edit(index: int, config: Dictionary) -> void:
	edit_index = index
	$AddConfig/Panel/Edit/Title/LineEdit.text = config["title"]
	$AddConfig/Panel/Edit/Nick/LineEdit.text = config["nick"]
	$AddConfig/Panel/Edit/Address/LineEdit.text = config["address"]
	$AddConfig/Panel/Edit/Port/LineEdit.text = config["port"]
	$AddConfig/Panel/Edit/Detail/TextEdit.text = config["detail"]
	add_config_avatar = config["avatar"]
	add_config_card_back = config["card_back"]
	$AddConfig/Panel/Avatar.texture_normal = GResourceManager.get_image_resoure(add_config_avatar)
	$AddConfig/Panel/CardBack.texture_normal = GResourceManager.get_image_resoure(add_config_card_back)
	$AddConfig.show()


func connect_config() -> void:
	pass


func make_dialog_config(title: String, detail: String, list_items: Array) -> Dictionary:
	return {
		"title": title,
		"detail": detail,
		"list": {
			"items": list_items,
			"max": 1,
			"min": 1,
		},
		"btns": [
			{"text": "确定", "callback":
				func(chooses):
					if chooses.size() == 0:
						return {
							"close": false,
							"choose_list": chooses,
							"choose_text": "Confirm"
						}
					return {
						"close": true,
						"choose_list": chooses,
						"choose_text": "Confirm"
					}},
			{"text": "取消", "callback":
				func(chooses): return {
						"close": true,
						"choose_list": chooses,
						"choose_text": "Cancel"
					}}
		]
	}


func _on_exit_page_pressed() -> void:
	AsyncScene.new(
		"res://pages/battle_mode/battle_mode.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()
