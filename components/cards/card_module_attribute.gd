extends Node3D
class_name CardAttribute

@onready var base_lv: Label3D = $LV
@onready var base_name: Label3D = $Name

@onready var attribute_primary: Label3D = $Attribute/Primary
@onready var attribute_secondary: Label3D = $Attribute/Secondary

@onready var karling_ap: Label3D = $Karling/AP
@onready var karling_dp: Label3D = $Karling/DP
@onready var karling_sp: Label3D = $Karling/SP
@onready var building_gp: Label3D = $Building/GP

var parent: CardEntity

func _ready() -> void:
	# parent = get_parent()
	
	# 清除预设的属性
	base_lv.text = ""
	base_name.text = ""
	attribute_primary.text = ""
	attribute_secondary.text = ""
	karling_ap.text = ""
	karling_dp.text = ""
	karling_sp.text = ""
	building_gp.text = ""



func update() -> void:
	var lv = int(parent.get_attr_by_id(&"lv").get_value())
	base_lv.text = "L" + str(lv)
	
	var step = 0
	var sub_arr = []
	# 卡名太长就需要拆分
	while step < parent.card_name.length():
		sub_arr.append(parent.card_name.substr(step, step + 5))
		step += 6
	var res = ""
	for sub in sub_arr:
		res += sub + "\n"
	
	base_name.text = res
	
	attribute_primary.text = parent.primary_attribute
	attribute_secondary.text = parent.secondary_attribute
	
	if parent.kind == "卡灵卡":
		var ap = int(parent.get_attr_by_id(&"ap").get_value())
		var dp = int(parent.get_attr_by_id(&"dp").get_value())
		var sp = int(parent.get_attr_by_id(&"sp").get_value())
		
		karling_ap.text = "A" + str(ap)
		karling_dp.text = "D" + str(dp)
		karling_sp.text = "S" + str(sp)


# FIXME: 为卡片添加属性模块
# func _process(_delta: float) -> void:
# 	if parent is not Card:
# 		return
	
# 	if parent.get_flip() == Card.Flip.FRONT and parent.area >= 100:
# 		var area = Utils.find_area(parent.area)
# 		if area == null:
# 			hide()
# 			return
# 		if visible == false and area.heap.get_child(area.heap.get_child_count() - 1) == parent:
# 			show()
# 		update()
# 	else: 
# 		if visible == true:
# 			hide()
	
# 	global_position = parent.global_position
# 	global_position.y += 0.001
	
# 	if Utils.find_player(parent.ownership).use_facility == Player.UseFacility.RED:
# 		base_lv.position.z = -0.05
# 		base_name.position.z = 0.15
# 		attribute_primary.position.z = -0.05
# 		attribute_secondary.position.z = -0.05
# 		karling_ap.position.z = -0.14
# 		karling_dp.position.z = -0.14
# 		karling_sp.position.z = -0.14
# 		building_gp.position.z = -0.14
# 	else:
# 		base_lv.position.z = 0.05
# 		base_name.position.z = -0.15
# 		attribute_primary.position.z = 0.05
# 		attribute_secondary.position.z = 0.05
# 		karling_ap.position.z = 0.14
# 		karling_dp.position.z = 0.14
# 		karling_sp.position.z = 0.14
# 		building_gp.position.z = 0.14
