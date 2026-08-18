## 命令类
extends RefCounted
class_name Command


var _args: Variant = null
var _execute_state = false


func is_execute() -> bool:
	return _execute_state

func args(param: Variant) -> Command:
	_args = param
	return self

## 命令类
## 所有命令类都需要继承这个类
## 命令类需要实现execute和undo方法
## execute方法用于执行命令
## undo方法用于撤销命令
func execute():
	if not is_execute():
		return
	_execute_state = true
	return


## 撤销命令
## 撤销execute方法执行的命令
func undo() -> void:
	pass
