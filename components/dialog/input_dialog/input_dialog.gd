extends CustomDialog
class_name InputDialog


func get_value():
	return $Dialog/VBox/LineEdit.text


func set_value(param: Dictionary) -> void:
	super(param)
	if param["can_hide"] == false:
		$Background/Visible.hide()
	if param.get("value"):
		$Dialog/VBox/LineEdit.text = param["value"]
	if param["placeholder"]:
		$Dialog/VBox/LineEdit.placeholder_text = param["placeholder"]


# override
func _bind_btn_callback(callback) -> void:
	var vs = get_value()
	
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
