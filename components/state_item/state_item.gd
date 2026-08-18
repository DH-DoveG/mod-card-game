extends TextureButton


@onready var entry: Label = $Entry
@onready var num: Label = $Num
@onready var serialization: Label = $Serialization

#var state_entry: StateEntry

# State 展示问题
# 1. 是否要在【行为】下面展示
# 2. 展示哪些数据
# 方案一：
# 1. 底部留一个【Top】状态
# 2. 其余状态通过在菜单标签页在【行为】-【状态】之间切换
# 3. 【状态】的显示：仅显示【名字】【时效】【来源】
#     3.1 考虑到【状态】由多个【状态Data】组成，若显示应当如何显示？
#     3.2 【时效】可能每个都有所不同，且来源也皆有所不同
#	    * 如何计算
# 现有结构：
# StateManager:
#     StateEntry:     ---- 仅作为容器
#         StateData1, ---- 实际数据
#         StateData2  ---- 实际数据
# 参考另一实现结构：
# BehaviorManager:
#     Behavior        ---- 实例
# State的设计在于：对于多重复属性的合并
# 如：效果无效状态，此时，若有来自的无效状态，那么就会发生重叠状态
# 应当给予它们合并
# 4. 给予 StateEntry 一个包含【名字】以及【状态Data个数】的Item
# 5. 点击【状态Data个数】显示一个面板，来列出 3 的信息
# 若此实施
#func set_state(state: StateEntry) -> void:
	#entry.text = state.name
	#num.text = str(state.state_datas.size())
	#serialization.text = state.serialization()
	#state_entry = state
