extends CustomDialog
class_name TabDialog

@onready var template_option_btn = $Template/Option
@onready var template_item = $Template/Item
@onready var template_tab_item = $Template/TabItem

@onready var tc = $Dialog/TabContainer

var item_values = []

var select_tab = 0
var select_value = null


func _ready() -> void:
	# set_value({
	# 	"title": "效果连锁对话框",
	# 	"detail": "有可进行的效果连锁操作",
	# 	"btns": [],
	# 	#
	# 	"tabs": [
	# 		{
	# 			"title": "C1",
	# 			"detail": "效果描述~~~",
	# 			"items": [
	# 				{
	# 					"text": "233",
	# 					"value": "behavior_id",
	# 					"background": ""
	# 				}
	# 			]
	# 		}
	# 	]
	# })
	pass


func set_value(param: Dictionary) -> void:
	# 复用代码
	super(param)
	# tabs : [ {
	# 	"title": "tab title",
	# 	"detail": "",
	# 	"options": [
	# 		{
	# 			"text": "option text",
	# 			"callback": <CALLBACK>
	# 		}
	# 	],
	# 	"items": [ { "text": "", "image": "RES_IMG_ID", "value": "" } ]
	# }, ... ]
	build_tabs(param["tabs"])


func build_tabs(tabs: Array):
	for tab in tabs:
		var tti = template_tab_item.duplicate()
		tc.add_child(tti)
		tc.set_tab_title(tc.get_child_count() - 1, tab["title"])
		tti.get_node("Info/HBoxContainer/VBoxContainer/TabDetails").append_text(tab["detail"])
		#_build_options(tti, tab["options"])
		_build_items(tti, tab["items"].values())
		tti.show()


#func _build_options(t: Control, config: Array):
	#var to = t.get_node("Info/TabOptions")
	#for op in config:
		#var tob = template_option_btn.duplicate()
		#to.add_child(tob)
		#tob.text = op["text"]
		#tob.pressed.connect(func():
			#print("OC: ", op["callback"])
		#)
		#tob.show()


func _build_items(t: Control, config: Array):
	# print("build_items: config: ", config)
	var to = t.get_node("TabItemList/HBox")
	var i = 0
	for item in config:
		var ti = template_item.duplicate(true)
		ti.name = "ITEM_" + str(i)
		# print("ti name: ", ti.name)
		to.add_child(ti)
		ti.get_node("Info/Label").text = item["text"]
		item_values.append(item.get("value", null))
		var img = GResourceManager.get_image_resoure(item["background"])
		if img:
			ti.get_node("Image").texture_normal = img
		ti.get_node("Image").pressed.connect(func():
			for node in $Dialog/TabContainer/TabItem/TabItemList/HBox.get_children():
				node.color = Color("#3e3e3e")
			ti.color = Color("#fff")
			#print("ti: ", ti.name)
			var index = int(ti.name.substr(5))
			select_value = item_values[index]
			# 显示选中的选项的值在 E2
			var behavior: Behavior = FindUtils.find_behavior(select_value)
			#print("SELECT BEHAVIOR: ", behavior)
			#TODO: 这里需要补完
			#待补完内容：
			t.get_node("Info/HBoxContainer/VBoxContainer2/TabDetails").text = behavior.get_info()["description"]
			
		)
		ti.show()
		i += 1


func _on_tab_container_tab_changed(tab: int) -> void:
	select_tab = tab
	select_value = null


# override
func _bind_btn_callback(callback) -> void:
	var vs = [select_tab, select_value]
	# 少一个value (btns)
	if typeof(callback) == TYPE_DICTIONARY:
		var func_cache_host_id = callback["cache_host_id"]
		var func_id = callback["id"]
		var v = await Utils.get_current_scene().rpc_awaiter.send_rpc(func_cache_host_id, Utils.get_current_scene().callback_cache.call_cache.bind(func_id, vs))
		if v["close"]:
			v.erase("close")
			select_clicked.emit(v["value"])
			call_deferred("queue_free")
		return
	
	if not callback.is_valid():
		vs.append(false)
		select_clicked.emit(vs)
		call_deferred("queue_free")
		return
	# 这里将用户的选择作为按钮的回调参数
	# 因为 chooses 的 key 只是方便切换点击状态用的，所以这里直接 values()
	var close = callback.call(vs)
	if close["close"]:
		close.erase("close")
		select_clicked.emit(close["value"])
		call_deferred("queue_free")
