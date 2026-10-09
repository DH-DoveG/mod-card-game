extends RefCounted
class_name Command

var _args: Variant = null
var _execute_state = false

func is_execute() -> bool:
	return _execute_state

func args(param: Variant) -> Command:
	_args = param
	return self

# command.gd 增强版
func execute():
	if is_execute():
		return
	var res = _do_execute()
	_execute_state = true
	return res

func _do_execute():
	pass  # 子类覆盖

func undo():
	if not is_execute():
		return
	_do_undo()
	_execute_state = false
	return

func _do_undo():
	pass  # 子类覆盖
