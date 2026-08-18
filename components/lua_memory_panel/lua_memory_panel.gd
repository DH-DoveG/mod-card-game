extends Control


## 这个组件用于显示Lua的内存占用情况


@onready var label = $Label


func _on_timer_timeout() -> void:
	var num = ModManager.state.globals["collectgarbage"].invoke("count")
	#if num / 1024 > 5:
		#print("LUA GC 开始")
		#ModManager.state.globals["collectgarbage"].invoke("count")
		#ModManager.state.globals["collectgarbage"].invoke("collect")
		#ModManager.state.globals["collectgarbage"].invoke("step")
		#ModManager.state.step_gc()
		#print("LUA GC 结束")
	label.text = "Lua脚本内存使用：" + str("%.6f" % (num / 1024)) + " MB"
	pass
