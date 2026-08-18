extends Object
class_name DataStruct


class LoadImageResoureStruct:
	var id: String = ""
	var path: String = ""
	var resource: Texture2D = null
	var tags: PackedStringArray = []

class LoadSoundResoureStruct:
	var id: String = ""
	var path: String = ""
	var resource: PackedByteArray = PackedByteArray()
	var tags: PackedStringArray = []


#FIXME: 关于数据集这一部分需要重新设计，弃用或调整
#这里的设计起初的目的：是为了把 Card、Player、Area 的部分对战相关的属性的“提取”
#然后因为 rpc 的问题，所以 Card节点 并不会移动到其他节点下，所有这里还收集了“卡片在何处”的数据
#这些或许可以作为 Card 的内置属性，给 Card 一个 AreaID 或者一个标识（在xx玩家的xx卡堆中）
#* 这里需要引入新概念（卡堆）（在场地外的卡堆如卡组、手牌、弃区）（在场地内的卡堆如“叠放”机制？这个机制需要Mod自行实现）
#* Core是不存在场地内的卡堆这个概念的（当然场地内卡是允许堆是允许实现的）
#> 或许是是“卡集”（CardSet）
#> 应当提供API来让场地内的卡可设置“堆积”
# ! 先把 DECK、GRAVEYARD 换成 CARD_SET
# # 通过这个枚举确定要修改的数据集
#enum BattleBindDataSetKey {
	#CARD_PUBLIC_INFORMATION,
	#CARD_BIND_BEHAVIORS,
	#AREA_BIND_CARDS,
	#CAMP_BIND_PLAYERS,
	#PLAYER_BIND_AREAS,
	#PLAYER_BIND_CARDS,
	## PLAYER_BIND_CARDS_OF_DECK, # !
	## PLAYER_BIND_CARDS_OF_GRAVEYARD, # !
	## PLAYER_BIND_CARDS_OF_HAND, # 手牌保留作为默认
	#CARD_SET, # Dictionary[<集合名称>, Dictionary[<玩家ID>, <卡片ID>]]
#}
class BattleBindDataStruct:
	# 一个卡片的信息可以公开给哪些玩家
	# 这里面的 value 是玩家的ID，这些玩家可以查看这张卡的信息（比如把鼠标移动到这张卡上）
	# 不在公开信息里的玩家不能试图打开操作面版操作这张卡
	# 不能查看这张卡的信息
	# * 最好可以在修改如卡片是否翻面之类的地方调整公开信息这里，这样其他地方直接用这里来决定玩家是否可以看到消息就可以了
	# （比如说在卡组中，它的公开信息应该是空数组，双方都无法查看）
	# （在手牌时，公开信息应该是这张卡控制者的ID，如果这张卡公示了，那么就所有人可见）
	# （在场上时，公开信息是所有人（is_front 为 true 时），否则只有这张卡的控制者可见）
	# （在墓地时，公开信息是所有人（is_front 为 true 时），否则无人可见）
	# 这个可以形成 card_id : [ player_id, ... ] 的关系
	var card_public_information: Dictionary[String, PackedStringArray] = {} # NEW
	# 一个卡片可以有多个行为
	var card_bind_behaviors: Dictionary[String, PackedStringArray] = {} # behavior
	# 一个区域可以存在多张卡片
	var area_bind_cards: Dictionary[String, PackedStringArray] = {} # heap
	# 一个区域可以被多个玩家持有
	var area_bind_players: Dictionary[String, PackedStringArray] = {} # area
	# 一个阵营可以有多个玩家
	var camp_bind_players: Dictionary[String, PackedStringArray] = {} # camp
	# 一个玩家可以有多个卡片（总共、在卡组、在手牌、在墓地）
	# ”卡片在哪“或许可以通过修改卡片的一个状态来实现，而不用反复的添加、移除数据
	# 不过在同步数据时，需要根据卡片的状态来判断卡片在哪，而不能直接根据卡片的ID来判断卡片在哪
	var player_bind_cards_of_ownership: Dictionary[String, PackedStringArray] = {} # 玩家与卡片的持有关系
	var player_bind_cards_of_controller: Dictionary[String, PackedStringArray] = {} # 玩家与卡片的控制关系
	# var player_bind_cards_of_deck: Dictionary[String, PackedStringArray] = {} # deck
	# var player_bind_cards_of_graveyard: Dictionary[String, PackedStringArray] = {} # graveyard
	# var player_bind_cards_of_hand: Dictionary[String, PackedStringArray] = {} # hand
	# CARD_SET Dictionary[<集合名称>, Dictionary[<玩家ID>, <卡片ID>]]
	# 模板： { "Hand": { 
	#             "config": {...}, 
	#             "data": { "PlayerID1": ["CardID1"...], "PlayerID2": ["CardID2"...] } 
	#       } }
	var card_set: Dictionary[String, Dictionary] = {}
	# 清理卡片脏数据
	# config: { type: null|"card_set"|"area", save: {set: "Hand"("card_set"), pid: ""}|"AREA_00000001"("area)... }
	func clean_card(card_id: String, config := {}) -> Array:
		var remove_for_sets = []
		var index = -1
		
		for k in area_bind_cards:
			if not config.is_empty() and config["type"] == "area" and config["save"] == k:
				continue
			index = area_bind_cards[k].find(card_id)
			if index != -1:
				area_bind_cards[k].remove_at(index)
		for key in card_set:
			#var has_changed := false
			for pid in card_set[key]["data"]:
				if not config.is_empty() and config["type"] == "card_set" and config["save"]["set"] == key and config["save"]["pid"] == pid:
					continue
				index = card_set[key]["data"][pid].find(card_id)
				if index != -1:
					card_set[key]["data"][pid].remove_at(index)
					#has_changed = true
			#if has_changed:
					remove_for_sets.append({
						"sets": key,
						"pid": pid
					})
		
		return remove_for_sets
