extends Node
class_name Battle

@onready var ui: CanvasLayer = $UI
@onready var scene: Scene = $SVC/SV/Scene
#@onready var player_mount: Node = $PlayerMount
#@onready var camp_mount: Node = $CampMount
@onready var world_environment: WorldEnvironment = $Environment/World
@onready var light_environment: DirectionalLight3D = $Environment/Light

var rule_manager = RuleManager.new() 
var event_manager = EventManager.new()
var timepoint_manager = TimepointManager.new()
@onready var callback_cache: Node = $CallbackCache
@onready var rpc_awaiter: RpcAwaiter = $RpcAwaiter

var host_player_id = "" # 主机玩家的ID（或许应该说是本地玩家的）
var host_is_audience = false # 主机玩家是否是观众


var visual_angle = Vector2i.DOWN :
	set(v):
		visual_angle = v
		if scene: scene.battle_visual_angle_changed(visual_angle)


# 0 也就是开始游戏前的回合
# 这个特殊的回合需要做、抽卡、调度
# 1 是开始回合，这个回合不进行【抽卡阶段】以及卡灵不能够攻击
# 2 及之后的回合可进行【抽卡阶段】以及卡灵能够攻击
var round_num = 0:
	set(v):
		var old = round_num
		round_num = v
		round_num_changed.emit(v, old)

signal round_num_changed(new_round, old_round)

# round_action_sequence 灵客行动列表
# round_index 表示现在进行到的列表的下标
# current_round_Player 表示现在回合灵客的id
var round_action_sequence: Array = []
var round_index = 0
var current_round_player: String = ""

var host_player: Player # 代表玩家的灵客
#var player_user_facility: Player.UseFacility = Player.UseFacility.NONE # 玩家使用的设备


var players := {} # 玩家ID: PlayerEntity
var cards := {} # 卡片ID: CardEntity
var camps := {} # 阵营ID: CampEntity
var behaviors := {} # 行为ID: Behavior
var areas := {} # 区域ID: AreaEntity


# 在等待玩家处理输入交互时，应当设置为 true
# 为 true 时，大部分行为不可操作
var in_option = true


# 游戏中产生的数据
var battle_global_data = {}


# 游戏中产生的数据绑定列表
var battle_data_bind_list: DataStruct.BattleBindDataStruct = DataStruct.BattleBindDataStruct.new()
#var battle_data_bind_list = {
	## behavior_id : card_id 多对少（一个行为只能被一张卡使用）
	## 结构： { "BEHAVIOR_00000001": "CARD_00000001", "BEHAVIOR_00000002": "CARD_00000002", ... }
	#"behavior": {},
	## card_id : player_id 多对少（一个灵客可以使用多张卡）
	## 结构： { "CARD_00000001": "PLAYER_00000000", "CARD_00000002": "PLAYER_00000000", ... }
	#"card": {},
	## area_id : player_id 少对多（一个区域可以被多个玩家占用）
	## 结构： { "AREA_00000001": [ "PLAYER_00000000", "PLAYER_00000001", ... ] }
	#"area": {},
	## area_id : card_id 多对少（一个区域可以有多个卡）
	## 结构： { "AREA_00000001": [ "CARD_00000001", "CARD_00000002", ... ] }
	#"heap": {},
	## player_id : camp 多对少（多个玩家对应一个阵营）
	## 结构： { "PLAYER_00000000": "CAMP1", ... }
	#"camp": {},
	## player_id : card_id 少对多
	## 结构： { "PLAYER_00000000": [ "CARD_00000000"， ... ] }
	#"deck": {},
	## player_id : card_id 少对多
	## 结构： { "PLAYER_00000000": [ "CARD_00000000"， ... ] }
	#"hand": {},
	## player_id : card_id 少对多
	## 结构： { "PLAYER_00000000": [ "CARD_00000000"， ... ] }
	#"graveyard": {},
	## player_id : area_id 少对多
	## 结构： { "PLAYER_00000000": [ "AREA_00000000"， ... ] }
	#"player_use_areas": {}
#}
