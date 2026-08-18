extends BaseDialog
class_name CustomDialog

###########################################################
## 自定义弹窗，可以自定义内容与按钮
###########################################################

@onready var top_title = $Dialog/Title
@onready var detail = $Dialog/Detail
@onready var option = $Dialog/Option

signal select_clicked

# btns: [{text = "按钮文本", callback = Callable}] as Array
# 对应配置项目，还包括：点击后是否关掉窗口，回调返回 true 就关掉，为 false 就不关闭窗口
#var confirmed_call: Callable # 确认后的回调
#var cancel: Callable # 取消后的回调
func set_value(param: Dictionary) -> void:
	top_title.text = param.title
	detail.text = param.detail
	_build_btns(param["btns"])


func _build_btns(btns: Array) -> void:
	# 遍历并生成按钮
	for config in btns:
		var btn = _build_btn_item(option, config["text"])
		btn.pressed.connect(_bind_btn_callback.bind(config["callback"]))


func _bind_btn_callback(callback: Callable) -> void:
	var close: Dictionary = callback.call()
	if close["close"]:
		close.erase("close")
		select_clicked.emit(close)
		queue_free() # 这个析构是析构弹窗自身
	pass


func _build_btn_item(parent: Node, text: String) -> Button:
	var btn = Button.new()
	parent.add_child(btn)
	btn.text = text
	btn.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
	btn.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
	return btn
