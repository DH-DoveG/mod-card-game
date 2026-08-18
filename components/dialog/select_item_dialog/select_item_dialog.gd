extends CustomDialog
class_name SelectItemDialog

@onready var temp_item = $Templates/Item
@onready var scroll = $Dialog/Scroll/HBox

var items = [] # 可选择
#var chooses = {} # 已选择，key=按钮名字，value=传入的value
var chooses = [] # 已选择，结构： [ [按钮名字, 传入的value], ... ]
var max_num = 1
var min_num = 0

const is_choose_color = Color("#FFF")
const not_choose_color = Color("#818181")


func set_value(param: Dictionary) -> void:
	# 参数检查
	if not param.has("list"):
		queue_free()
		return
	# 复用代码
	super(param)
	# 构建列表
	_build_list(param["list"])


# override
func _bind_btn_callback(callback) -> void:
	var vs = []
	for i in chooses:
		vs.append(i[1])
	
	if typeof(callback) == TYPE_DICTIONARY:
		var func_cache_host_id = callback["cache_host_id"]
		var func_id = callback["id"]
		var v = await Utils.get_current_scene().rpc_awaiter.send_rpc(func_cache_host_id, Utils.get_current_scene().callback_cache.call_cache.bind(func_id, vs))
		if v["close"]:
			v.erase("close")
			select_clicked.emit(v)
			call_deferred("queue_free")
		return
	
	if not callback.is_valid():
		select_clicked.emit(vs)
		call_deferred("queue_free")
		return
	# 这里将用户的选择作为按钮的回调参数
	# 因为 chooses 的 key 只是方便切换点击状态用的，所以这里直接 values()
	var close = await callback.call(vs)
	if close["close"]:
		close.erase("close")
		select_clicked.emit(close)
		call_deferred("queue_free")


func _build_list(list: Dictionary) -> void:
	items = list["items"]
	max_num = list["max"]
	min_num = list["min"]
	# FIXME: 如果 item.id 不能作为节点名称呢？
	# 那某只能用 .bind 来绑定参数了
	for item in items:
		var dup = temp_item.duplicate()
		scroll.add_child(dup)
		var img = item.get("background")
		if img:
			dup.get_node("Image").texture_normal = GResourceManager.get_image_resoure(item["background"])
		dup.get_node("Label").text = item.text
		dup.get_node("Image").pressed.connect(_list_item_pressed.bind(dup, item))
		dup.show()


# 列表选项的点击处理
func _list_item_pressed(btn: ColorRect, param: Dictionary) -> void:
	# 查询是否存在（已选择），有则移除，无则添加
	for i in chooses:
		if i[0] == btn.name:
			btn.color = not_choose_color
			chooses.erase(i)
			return
	# 如果满了就替换第一个
	if chooses.size() == max_num:
		if chooses.is_empty(): return
		var first = chooses.pop_front()
		scroll.get_node(str(first[0])).color = not_choose_color
	btn.color = is_choose_color
	chooses.append([btn.name, param.value])
