extends Page


@onready var all_mod_list = $AllMod/List/VBox
@onready var load_mod_list = $LoadMod/List/VBox
@onready var mod_content = $ModContent/Scroll/RichText

# mod 列表展示页
# 该页需要能够展示所有存在的 mod
# 该页需要能够对点击的 mod 查看到详细信息
# 该页决定了要有哪些 mod 应用
# * 对于 mod 的介绍信息，应当允许 BBCODE 格式显示

var load_list: Array[Dictionary] = []


func _init() -> void:
	page_id = "MOD_PAGE"


func _ready() -> void:
	super ()
	#_load_mods()
	_build_mod_list_view()


func _load_mods() -> void:
	print("load_mods: ", ConfigManager.get_mod_env_paths())
	#GCommandManager.execute(
	ModProbeCommand.new().args({"paths": ConfigManager.get_mod_env_paths()}).execute()
	#)


func _build_mod_list_view() -> void:
	for i in ModManager.probe_mods:
		# 这里是为了应对二次打开页面的效果，因为第二次打开页面时，需要将第一次打开时的Mod列表也进行加载
		# 所以这里需要对Mod加载情况进行保存
		var key = false
		for u in ModManager.use_mods:
			var iid = i["load_introducer_info"]["id"]
			var uid = u["load_introducer_info"]["id"]
			if iid == uid:
				_build_load_mod_list_view(i["load_introducer_info"], i)
				key = true
				break
		if not key:
			_build_all_mod_list_view_item(i["load_introducer_info"], i)


#region 未加载的模组列表
func _build_all_mod_list_view_item(item: LuaTable, i: Dictionary) -> void:
	var all_mod_list_item_template: Button = $Templates/AllModListItemTemplate
	var copy = all_mod_list_item_template.duplicate()
	all_mod_list.add_child(copy)
	copy.get_node("Label").text = item["name"] + "\n" + \
								  "作者: " + item["author"] + "\n" + \
								  "版本: " + item["version"]
								  # dependency 依赖
	copy.pressed.connect(_show_mod_description.bind(item["description"]))
	copy.get_node("Add").pressed.connect(_add_mod_to_load_list.bind(copy, item, i))
	copy.show()


func _add_mod_to_load_list(item: Button, mod: LuaTable, i) -> void:
	item.queue_free()
	_build_load_mod_list_view(mod, i)
#endregion


func _show_mod_description(text: String) -> void:
	mod_content.clear()
	mod_content.append_text(text)


#region 加载了的模组列表
func _build_load_mod_list_view(mod: LuaTable, i: Dictionary) -> void:
	var load_mod_list_item_template: Button = $Templates/LoadModListItemTemplate
	var copy = load_mod_list_item_template.duplicate()
	load_mod_list.add_child(copy)
	copy.get_node("Label").text = mod["name"] + "\n" + \
								  "作者: " + mod["author"] + "\n" + \
								  "版本: " + mod["version"]
	copy.pressed.connect(_show_mod_description.bind(mod["description"]))
	copy.get_node("Remove").pressed.connect(_add_mod_to_all_list.bind(copy, mod, i))
	copy.show()
	load_list.append(i)


func _add_mod_to_all_list(item: Button, mod: LuaTable, i: Dictionary) -> void:
	item.queue_free()
	_build_all_mod_list_view_item(mod, i)
	load_list.erase(i)
#endregion


func _on_use_pressed() -> void:
	# 这里是在应用Mod时，将使用的Mod的信息在used_mods_list中保存
	# 这一块需要放到 ModData 中
	# ModManager.used_mods_list = load_list
	# ModManager.use_mods = load_list
	# ModManager.load_used_mods()
	# TODO: 这里调用，但是不接受返回值，改变页面之类的效果应该是由mod调用API来实现的
	# ModManager.starter({
	# 	"type": "PAGE",
	# })
	# print("Load List: ", load_list)
	#GCommandManager.execute(
	ModUseCommand.new().args({"mods": load_list}).execute()
	#)
	# print("===============")

	AsyncScene.new(
		"res://pages/index.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_return_back_pressed() -> void:
	# print("Return Back")
	AsyncScene.new(
		"res://pages/index.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()
