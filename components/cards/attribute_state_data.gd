#extends StateData
#class_name AttributeStateData
#
#@export var base_lv = -1
#@export var base_name = ""
#@export var attribute_primary = ""
#@export var attribute_secondary = ""
#@export var karling_ap = -1
#@export var karling_dp = -1
#@export var karling_sp = -1
#@export var building_gp = -1
#
#@export var control_is_show = false
#
#
#func handle_calculate_result(calculate_result: Dictionary) -> Dictionary:
	#return calculate_result
#
#
#func handle_calculate_result_step(calculate_result: Dictionary, _state_data: StateData) -> Dictionary:
	#return calculate_result
#
#func calculate(_arg: Dictionary) -> Dictionary:
	#return {
		#"base_lv" = base_lv,
		#"base_name" = base_name,
		#"attribute_primary" = attribute_primary,
		#"attribute_secondary" = attribute_secondary,
		#"karling_ap" = karling_ap,
		#"karling_dp" = karling_dp,
		#"karling_sp" = karling_sp,
		#"building_gp" = building_gp,
		#"control_is_show" = control_is_show
	#}
