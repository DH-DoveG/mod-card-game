extends Page


@onready var search_card_dialog = $SearchCardDialog


# 需要建立一个简易“数据库”
var card_data_library = []
var card_value_types = []
var card_types = []
var ids = []

var file_name = ""
var file_obj: FileAccess = null

func _init_card_library():
	var v = {}
	var t = {}
	for ckey in GResourceManager.card_resource:
		var id = IDUtils.generate("__CardDataDeckLibrary__")
		var ce: CardEntity = GApiManager.card_api.create_entity(id, ckey)
		add_child(ce)
		ids.append(id)
		card_data_library.append(ce)
		if not ce.meta["type"].is_empty():
			t[ce.meta["type"]] = true
		for value in ce.value_manager.keys():
			v[value] = true
	card_value_types = v.keys()
	card_types = t.keys()


func _exit_tree() -> void:
	for ce in card_data_library:
		if ce.name in ids:
			ce.queue_free()


func search(config: Dictionary):
	if config.is_empty():
		build_srv(card_data_library)
	else:
		var card_name = config["card_name"]
		var card_type = config["card_type"]
		var card_values = config["card_values"]
		var card_tags = config["card_tags"]
		var card_behaviors = config["card_behaviors"]
		var cs = []
		for cdl: CardEntity in card_data_library:
			var key = false
			if not card_name.is_empty() and cdl.card_name != card_name:
				continue
			if not card_type.is_empty() and cdl.meta["type"] != card_type:
				continue
			for tag in card_tags:
				if tag not in cdl.tags:
					key = true
					break
			if key:
				continue
			key = false
			for value in card_values:
				if not cdl.value_manager.has(value):
					key = true
					break
				if cdl.value_manager[value].value != card_values[value]:
					key = true
					break
			if key:
				continue
			key = false
			var count = 0
			for behavior in card_behaviors:
				for b: Behavior in cdl.behavior_manager.behaviors:
					if b.get_info()["description"].contains(behavior):
						count += 1
			if not card_behaviors.is_empty() and count == 0:
				break
			cs.append(cdl)
		build_srv(cs)


func to_dict():
	var card_stacks = []
	for v in $Scroll/VBox.get_children():
		var title = v.get_title()
		var cs = []
		for i in v.grid.get_children():
			if i is CardView:
				cs.append(i.data.get_code())
		card_stacks.append({
			"title": title,
			"content": cs
		})
	return {
		"name": "",
		"details": "",
		"cover": "",
		"stack": card_stacks
	}


func reload_sc():
	var sdvho = $SearchCardDialog/Dialog/VBox/HBox/Option
	sdvho.clear()
	sdvho.add_item("")
	for dscc in ConfigManager.deck_search_condition_config:
		sdvho.add_item(dscc)
	sdvho = $SearchBox/Top/HBox/SearchOption
	sdvho.clear()
	sdvho.add_item("")
	for dscc in ConfigManager.deck_search_condition_config:
		sdvho.add_item(dscc)


func _on_sc_delete_pressed() -> void:
	var sdvho = $SearchCardDialog/Dialog/VBox/HBox/Option
	ConfigManager.deck_search_condition_config.erase(sdvho.get_item_text(sdvho.selected))
	var f = str(ConfigManager.deck_search_condition_config)
	var _file = PersistenceUtils.open_file(ConfigManager.DECK_SEARCH_CONDITION_CONFIG_FILE_PATH)
	_file.resize(f.length())
	_file.store_string(f)
	reload_sc()


func build_srv(cdls: Array):
	for i in $SearchBox/Result/VBox.get_children():
		i.queue_free()
	for cdl: CardEntity in cdls:
		var si = load("res://pages/deck_editor/search_item.tscn").instantiate()
		$SearchBox/Result/VBox.add_child(si)
		si.set_card(cdl)
		si.change_status.connect(func(c: CardEntity, s):
			if s:
				#$Status/Label.text = file_name + " | " + "待添加卡片：" + c.card_name
				update_status({ "添加卡片": c.card_name })
			for _c in $SearchBox/Result/VBox.get_children():
				if _c.data != c:
					_c.status = false
					_c.switch_btn_icon()
			for _c in $Scroll/VBox.get_children():
				_c.show_add_card(c, s)
		)


# 编辑卡组
func _init() -> void:
	page_id = "DECK_EDITOR_PAGE"


func _ready() -> void:
	super ()
	
	_init_card_library()
	
	var card_type = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Top/Type/Option
	card_type.add_item("")
	for ct in card_types:
		card_type.add_item(ct)
	
	reload_sc()
	
	search({})


func _on_create_card_set_pressed() -> void:
	var cds = load("res://pages/deck_editor/card_deck_stack.tscn").instantiate()
	$Scroll/VBox.add_child(cds)


func _on_search_card_dialog_close_pressed() -> void:
	search_card_dialog.hide()


func _on_search_card_dialog_pressed() -> void:
	search(get_search_card_dialog_data())


func _on_search_card_dialog_save_pressed() -> void:
	var value = $SearchCardDialog/Dialog/VBox/HBox/Option.get_item_text($SearchCardDialog/Dialog/VBox/HBox/Option.selected)
	var dialog = DialogUtils.show_input_dialog({
		"title": "保存搜索预设方案",
		"detail": "请输入预设名称",
		"value": value,
		"can_hide": false,
		"placeholder": "请输入预设名称",
		"btns": [
			{"text": "确定",
				"callback": func(_v):
					var close = true
					if _v.is_empty(): close = false
					return {
						"close": close,
						"value": _v,
						"choose": "Confirm"
				}},
			{"text": "取消",
				"callback": func(_v):
					return {
						"close": true,
						"value": _v,
						"choose": "Cancel"
				}},
		]
	})
	var v = await dialog.select_clicked
	if v["choose"] != "Confirm": return
	var data = get_search_card_dialog_data()
	ConfigManager.deck_search_condition_config[v["value"]] = data
	var f = str(ConfigManager.deck_search_condition_config)
	var _file = PersistenceUtils.open_file(ConfigManager.DECK_SEARCH_CONDITION_CONFIG_FILE_PATH)
	_file.resize(f.length())
	_file.store_string(f)
	reload_sc()


func get_search_card_dialog_data():
	var card_name = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Top/CardName/LineEdit.text
	var card_type = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Top/Type/Option.get_item_text($SearchCardDialog/Dialog/VBox/Scroll/VBox/Top/Type/Option.selected)
	var card_values = {}
	var card_tags = []
	var card_behaviors = []
	# value
	var _cvs = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Values/Grid.get_children()
	_cvs.pop_back()
	for v in _cvs:
		var id = v.get_node("Item").get_item_text(v.get_node("Item").selected)
		if id.is_empty():
			continue
		var value = v.get_node("Line").value
		card_values[id] = int(value)
	# tag
	var _cvt = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Tags/Grid.get_children()
	_cvt.pop_back()
	for v in _cvt:
		card_tags.append(v.get_node("Line").text)
	# behavior
	var _cvb = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Behaviors/Grid.get_children()
	_cvb.pop_back()
	for v in _cvb:
		card_behaviors.append(v.get_node("Text").text)
	# 检查
	print("NAME: ", card_name)
	print("TYPE: ", card_type)
	print("VALUE: ", card_values)
	print("TAG: ", card_tags)
	print("BEHAVIOR: ", card_behaviors)
	# 过滤
	return {
		"card_name": card_name,
		"card_type": card_type,
		"card_values": card_values,
		"card_tags": card_tags,
		"card_behaviors": card_behaviors
	}


func _on_search_popup_pressed() -> void:
	search_card_dialog.show()


func _on_scd_values_add_pressed() -> void:
	var add = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Values/Grid/Add
	var grid = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Values/Grid
	var template = $SearchCardDialog/Template/ValueTemplate.duplicate(true)
	grid.add_child(template)
	grid.move_child(add, grid.get_child_count())
	template.show()
	template.get_node("Delete").pressed.connect(func():
		template.queue_free()
	)
	var item: OptionButton = template.get_node("Item")
	for v in card_value_types:
		item.add_item(v)


func _on_scd_tag_add_pressed() -> void:
	var add = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Tags/Grid/Add
	var grid = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Tags/Grid
	var template = $SearchCardDialog/Template/TagTemplate.duplicate(true)
	grid.add_child(template)
	grid.move_child(add, grid.get_child_count())
	template.show()
	template.get_node("Delete").pressed.connect(func():
		template.queue_free()
	)


func _on_scd_behavior_add_pressed() -> void:
	var add = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Behaviors/Grid/Add
	var grid = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Behaviors/Grid
	var template = $SearchCardDialog/Template/BehaviorTextTemplate.duplicate(true)
	grid.add_child(template)
	grid.move_child(add, grid.get_child_count())
	template.show()
	template.get_node("Delete").pressed.connect(func():
		template.queue_free()
	)


func _on_option_item_selected(index: int) -> void:
	if index == 0: return
	var sdvho = $SearchCardDialog/Dialog/VBox/HBox/Option
	var config = ConfigManager.deck_search_condition_config[sdvho.get_item_text(sdvho.selected)]
	# 设置卡名
	$SearchCardDialog/Dialog/VBox/Scroll/VBox/Top/CardName/LineEdit.text = config["card_name"]
	# 设置卡片种类
	var cto = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Top/Type/Option
	var i = card_types.find(config["card_type"])
	if i != -1:
		cto.selected = i + 1
		pass
	#for i in range(cto.item_count):
		#if cto.get_item_text(i) == config["card_type"]:
			#cto.selected = i
			#break
	# 设置数值
	var ctv = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Values/Grid.get_children()
	ctv.pop_back()
	for v in config["card_values"]:
		i = card_value_types.find(v)
		var k = false
		for c in ctv:
			if c.get_node("Item").selected == i:
				c.get_node("Line").value = config["card_values"][v]
				k = true
				break
		if not k:
			# 每找到就添加一个
			_on_scd_values_add_pressed()
			var vv = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Values/Grid.get_children()[-2]
			vv.get_node("Item").selected = i
			vv.get_node("Line").value = config["card_values"][v]
	# 添加标签
	var ctt = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Tags/Grid.get_children()
	ctt.pop_back()
	for v in config["card_tags"]:
		var k = false
		for c in ctt:
			if c.get_node("Line").text == v:
				k = true
				break
		if not k:
			# 每找到就添加一个
			_on_scd_tag_add_pressed()
			var vv = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Tags/Grid.get_children()[-2]
			vv.get_node("Line").text = v
	# 添加行为
	var ctb = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Behaviors/Grid.get_children()
	ctb.pop_back()
	for v in config["card_behaviors"]:
		var k = false
		for c in ctb:
			if c.get_node("Text").text == v:
				k = true
		if not k:
			# 每找到就添加一个
			_on_scd_behavior_add_pressed()
			var vv = $SearchCardDialog/Dialog/VBox/Scroll/VBox/Tags/Grid.get_children()[-2]
			vv.get_node("Line").text = v


func _on_search_option_item_selected(index: int) -> void:
	var sdvho = $SearchBox/Top/HBox/SearchOption
	var config = ConfigManager.deck_search_condition_config.get(sdvho.get_item_text(index), {})
	search(config)


# 文件相关


func _on_deck_save_as_file_pressed() -> void:
	if not file_obj: return
	var dialog = DialogUtils.show_input_dialog({
		"title": "另存卡组",
		"detail": "请输入副本名称。这将当前的内容作为新卡组内容，而关闭当前文件。",
		"can_hide": false,
		"placeholder": "请输入卡组名称",
		"btns": [
			{"text": "确定",
				"callback": func(_v):
					var close = true
					if _v.is_empty(): close = false
					if PersistenceUtils.find_file(ConfigManager.DECK_FOLDER_PATH, _v + ".json"):
						ToastUtils.error("文件已存在")
						return
					return {
						"close": close,
						"value": _v,
						"choose": "Confirm"
				}},
			{"text": "取消",
				"callback": func(_v):
					return {
						"close": true,
						"value": _v,
						"choose": "Cancel"
				}},
		]
	})
	var v = await dialog.select_clicked
	if v["choose"] != "Confirm": return
	var _file_name = v["value"] + ".json"
	var _file_obj = PersistenceUtils.open_file(ConfigManager.DECK_FOLDER_PATH.path_join(_file_name))
	var context = str(to_dict())
	_file_obj.store_string(context)
	_file_obj.flush()
	file_obj.close()
	file_name = _file_name
	file_obj = _file_obj
	update_status({})
	ToastUtils.info("卡组副本已创建")


func _on_deck_create_file_pressed() -> void:
	var dialog = DialogUtils.show_input_dialog({
		"title": "创建卡组",
		"detail": "请输入卡组名称",
		"can_hide": false,
		"placeholder": "请输入卡组名称",
		"btns": [
			{"text": "确定",
				"callback": func(_v):
					var close = true
					if _v.is_empty(): close = false
					if PersistenceUtils.find_file(ConfigManager.DECK_FOLDER_PATH, _v + ".json"):
						ToastUtils.error("文件已存在")
						return
					return {
						"close": close,
						"value": _v,
						"choose": "Confirm"
				}},
			{"text": "取消",
				"callback": func(_v):
					return {
						"close": true,
						"value": _v,
						"choose": "Cancel"
				}},
		]
	})
	var v = await dialog.select_clicked
	if v["choose"] != "Confirm": return
	var _file_name = v["value"] + ".json"
	var _file_obj = PersistenceUtils.open_file(ConfigManager.DECK_FOLDER_PATH.path_join(_file_name))
	_file_obj.store_string(str({
		"name": "",
		"details": "",
		"cover": "",
		"stack": []
	}))
	_file_obj.close()


func _on_save_file_pressed() -> void:
	if not file_obj: return
	var context = str(to_dict())
	file_obj.resize(context.length())
	file_obj.store_string(context)
	file_obj.flush()
	ToastUtils.info("卡组已保存")


# 根据卡组配置反推生成
func load_deck(config: Dictionary):
	for _sv in $Scroll/VBox.get_children():
		_sv.queue_free()
	for _c in $SearchBox/Result/VBox.get_children():
		_c.status = false
		_c.switch_btn_icon()
	for _s in config["stack"]:
		var cds = load("res://pages/deck_editor/card_deck_stack.tscn").instantiate()
		$Scroll/VBox.add_child(cds)
		cds.get_node("Top/LineEdit").text = _s["title"]
		for c in _s["content"]:
			for ce: CardEntity in card_data_library:
				if c == ce.get_code():
					cds.add_card(ce)
					break


func _on_deck_list_pressed() -> void:
	var files = PersistenceUtils.folder_all_files(ConfigManager.DECK_FOLDER_PATH)
	files = files.filter(func(_v): return _v.ends_with(".json"))
	var dialog = DialogUtils.show_option_dialog({
		"title": "卡组列表",
		"detail": "请选择一个卡组",
		"can_hide": false,
		"list": files,
		"btns": [
			{"text": "确定",
				"callback": func(_v):
					var close = true
					if _v == file_name: 
						ToastUtils.error("当前已打开该卡组")
						close = false
					return {
						"close": close,
						"value": _v,
						"choose": "Confirm"
				}},
			{"text": "取消",
				"callback": func(_v):
					return {
						"close": true,
						"value": _v,
						"choose": "Cancel"
				}},
		]
	})
	var v = await dialog.select_clicked
	if v["choose"] != "Confirm": return
	var text = v["value"]
	open_deck(text)


func open_deck(_file_name: String):
	var file = PersistenceUtils.open_file(ConfigManager.DECK_FOLDER_PATH.path_join(_file_name))
	file_name = _file_name
	file_obj = file
	update_status({})
	load_deck(JSON.parse_string(file.get_as_text()))


func update_status(config: Dictionary):
	var file = file_name
	if file.is_empty():
		file = "*当前未打开卡组文件"
	var content = file
	var c = []
	for key in config:
		c.append(key + "：" + config[key])
	if c.size() > 1:
		content += " | ".join(c)
	elif c.size() == 1:
		content += " | " + c[0]
	$Status/Label.text = content


func _on_deck_check_tool_pressed() -> void:
	if not file_obj: return
	var dialog = DialogUtils.show_option_dialog({
		"title": "卡组检查",
		"detail": "请选择一个检查工具",
		"can_hide": false,
		"list": GResourceManager.deck_check_tool_resource.keys(),
		"btns": [
			{"text": "确定",
				"callback": func(_v):
					return {
						"close": true,
						"value": _v,
						"choose": "Confirm"
				}},
			{"text": "取消",
				"callback": func(_v):
					return {
						"close": true,
						"value": _v,
						"choose": "Cancel"
				}},
		]
	})
	var v = await dialog.select_clicked
	if v["choose"] != "Confirm": return
	var fun = ModManager.do_mod_file(GResourceManager.deck_check_tool_resource[v["value"]])
	#print(">>> ", to_dict())
	var table = LuaUtils.dictionary_to_table(to_dict())
	var result = fun.invoke(table)
	#print(LuaUtils.table_to_dictionary(result))
	var r = LuaUtils.table_to_dictionary(result).values()
	for vv in r:
		var text = "卡堆：" + vv["stack"] + " | 信息：" + vv["message"]
		if vv["result"]:
			ToastUtils.success(text)
		else:
			ToastUtils.error(text)


func _on_close_pressed() -> void:
	AsyncScene.new(
		"res://pages/index.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_deck_delete_pressed() -> void:
	file_obj.close()
	DirAccess.remove_absolute(PersistenceUtils.get_exec_path().path_join(ConfigManager.DECK_FOLDER_PATH).path_join(file_name))
