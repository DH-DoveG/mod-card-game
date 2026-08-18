extends Node
#class_name ResourceManager

var image_resource: Array[DataStruct.LoadImageResoureStruct] = []
var music_resource: Array[DataStruct.LoadSoundResoureStruct] = []
var sound_resource: Array[DataStruct.LoadSoundResoureStruct] = []
var value_resource: Dictionary[String, String] = {} # 数值资源：数值资源路径
var card_resource: Dictionary[String, String] = {} # 卡片编号:卡片资源路径
var deck_resource: Dictionary[String, String] = {} # 卡组名称：卡组资源路径
var player_resource: Dictionary = {}
var player_entitys_resource: Dictionary[String, String] = {}
var behavior_resource: Dictionary[String, String] = {}
var deck_check_tool_resource: Dictionary[String, String] = {}
var agent_resource: Dictionary[String, String] = {}
var package_resource: Dictionary[String, String] = {}
var start_rule_resource: PackedStringArray = []

func clear() -> void:
	image_resource.clear()
	music_resource.clear()
	sound_resource.clear()
	card_resource.clear()
	deck_resource.clear()
	player_resource.clear()
	player_entitys_resource.clear()
	behavior_resource.clear()
	package_resource.clear()
	start_rule_resource.clear()
	deck_check_tool_resource.clear()


func load_music_resoure(id: String, path: String, _tags: PackedStringArray = []) -> void:
	var struct = DataStruct.LoadSoundResoureStruct.new()
	struct.id = id
	struct.path = path
	struct.tags = _tags
	struct.resource = FileAccess.get_file_as_bytes(path)
	sound_resource.append(struct)


func get_music_resoure(id: String) -> PackedByteArray:
	for i: DataStruct.LoadSoundResoureStruct in music_resource:
		if i.id == id:
			return i.resource
	return PackedByteArray()


func unload_music_resoure(id: String) -> void:
	for i: DataStruct.LoadSoundResoureStruct in music_resource:
		if i.id == id:
			music_resource.erase(i)


func load_sound_resoure(id: String, path: String, _tags: PackedStringArray = []) -> void:
	var struct = DataStruct.LoadSoundResoureStruct.new()
	struct.id = id
	struct.path = path
	struct.tags = _tags
	struct.resource = FileAccess.get_file_as_bytes(path)
	sound_resource.append(struct)


func unload_sound_resoure(id: String) -> void:
	for i: DataStruct.LoadSoundResoureStruct in sound_resource:
		if i.id == id:
			sound_resource.erase(i)


func get_sound_resoure(id: String) -> DataStruct.LoadSoundResoureStruct:
	for i: DataStruct.LoadSoundResoureStruct in sound_resource:
		if i.id == id:
			return i
	return null


func load_image_resoure(id: String, path: String, tags: PackedStringArray = []) -> void:
	var struct = DataStruct.LoadImageResoureStruct.new()
	struct.id = id
	struct.path = path
	struct.tags = tags
	#struct.resource = null #ImageUtils.path_to_image(path)
	struct.resource = ImageUtils.path_to_image(path)
	image_resource.append(struct)


func unload_image_resoure(id: String) -> void:
	for i: DataStruct.LoadImageResoureStruct in image_resource:
		if i.id == id:
			image_resource.erase(i)


func get_image_resoure(id: String) -> Texture2D:
	for i: DataStruct.LoadImageResoureStruct in image_resource:
		if i.id == id:
			if not i.resource: 
				i.resource = ImageUtils.path_to_image(i.path)
			#print("Resource 引用计数： ", i.id, " -->", i.resource.get_reference_count())
			return i.resource
			#return ImageUtils.path_to_image(i.path)
	return null
#
#func _process(_delta: float) -> void:
	#for img in image_resource:
		#if is_instance_valid(img.resource) and img.resource.get_reference_count():
			#if img.resource.get_reference_count() == 2:
				#print(img.id, " :移除不再使用的图片资源 ？ GRC: ", img.resource.get_reference_count())
				##img.resource.free()
				#img.resource = null
