extends Object
class_name DialogUtils


static func show_custom_dialog(param: Dictionary) -> BaseDialog:
	return show_dialog(param, load("res://components/dialog/custom_dialog/custom_dialog.tscn"))


static func show_select_item_dialog(param: Dictionary) -> BaseDialog:
	return show_dialog(param, load("res://components/dialog/select_item_dialog/select_item_dialog.tscn"))


static func show_select_image_dialog(param: Dictionary) -> BaseDialog:
	return show_dialog(param, load("res://components/dialog/select_image_dialog/select_image_dialog.tscn"))


static func show_input_dialog(param: Dictionary) -> BaseDialog:
	return show_dialog(param, load("res://components/dialog/input_dialog/input_dialog.tscn"))


static func show_option_dialog(param: Dictionary) -> BaseDialog:
	return show_dialog(param, load("res://components/dialog/option_dialog/option_dialog.tscn"))


static func show_dialog(param: Dictionary, resource: Resource) -> BaseDialog:
	var dialog = resource.instantiate()
	Utils.get_current_scene().add_child(dialog)
	dialog.set_value(param)
	dialog.show()
	return dialog
