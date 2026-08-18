extends Object
class_name ImageUtils

static func byte_to_image(data: PackedByteArray, suffix: String) -> Texture2D:
	var img: Image = Image.new()
	if suffix == "png":
		img.load_png_from_buffer(data)
	elif suffix == "jpg" or suffix == "jpeg":
		img.load_jpg_from_buffer(data)
	# print("suffix: ", suffix)
	return ImageTexture.create_from_image(img)

static func path_to_image(path: String) -> Texture2D:
	if path.begins_with("res://"):
		var resource: CompressedTexture2D = load(path)
		return resource
	var img = Image.load_from_file(path)
	img.generate_mipmaps() # 从外部文件系统加载进来的文件需要手动补生成一个 mipmaps
	return ImageTexture.create_from_image(img)

static func clip_image(image: Image) -> Texture2D:
	if image == null:
		return null
	var res: ImageTexture = null
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width != height:
		var clip: int = min(width, height)
		var _max: int = max(width, height)
		if width > height:
			res = ImageTexture.create_from_image(image.get_region(Rect2(float(_max - clip) / 2, 0, clip, clip)))
		else:
			res = ImageTexture.create_from_image(image.get_region(Rect2(0, float(_max - clip) / 2, clip, clip)))
	else:
		res = ImageTexture.create_from_image(image)
	return res

static func merge_dictionaries(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var result: Dictionary = dict1.duplicate() # 复制第一个字典以避免修改原始字典
	var keys: Array = dict2.keys()
	for i in range(keys.size()):
		var key: Variant = keys[i]
		var value2: Variant = dict2[key]
		if result.has(key):
			var value1: Variant = result[key]
			match typeof(value1):
				TYPE_INT:
					if typeof(value2) == TYPE_INT:
						result[key] = value1 + value2
				TYPE_FLOAT:
					if typeof(value2) == TYPE_FLOAT:
						result[key] = value1 + value2
					elif typeof(value2) == TYPE_INT:
						result[key] = value1 + float(value2)
				TYPE_STRING, TYPE_STRING_NAME:
					if typeof(value2) == TYPE_STRING or typeof(value2) == TYPE_STRING_NAME:
						result[key] = value2
				TYPE_ARRAY:
					if typeof(value2) == TYPE_ARRAY:
						var array1: Array = value1
						var array2: Array = value2
						array1.append(array2)
						result[key] = array1
				TYPE_DICTIONARY:
					if typeof(value2) == TYPE_DICTIONARY:
						var sub_dict1: Dictionary = value1
						var sub_dict2: Dictionary = value2
						result[key] = merge_dictionaries(sub_dict1, sub_dict2)
				_:
					# 对于其他类型，直接覆盖
					result[key] = value2
		else:
			# 如果key不存在于dict1中，就意味着不冲突，直接添加
			result[key] = value2
	return result

static func make_card_criterion_card_uv(front: Image, back: Image, border = Color("E5E5E5"), coefficient = 0.5) -> Texture2D:
	var uv_size: int = int(2048 * coefficient)
	var image_width: int = int(1024 * coefficient)
	var image_height: int = int(1430 * coefficient)
	var offset_y: int = int(618 * coefficient)
	#var uv_size: int = int(1024 * coefficient)
	#var image_width: int = int(512 * coefficient)
	#var image_height: int = int(715 * coefficient)
	#var offset_y: int = int(309 * coefficient)
	
	var combined_image: Image = Image.create_empty(uv_size, uv_size, false, Image.FORMAT_RGB8)
	combined_image.fill(border)
	
	if front == null:
		front = Image.create_empty(image_width, image_height, false, Image.FORMAT_RGB8)
		front.fill(border)
	if back == null:
		back = Image.create_empty(image_width, image_height, false, Image.FORMAT_RGB8)
		back.fill(border)
	
	if front.get_size() != Vector2i(image_width, image_height):
		front.resize(image_width, image_height, Image.INTERPOLATE_BILINEAR)
	if back.get_size() != Vector2i(image_width, image_height):
		back.resize(image_width, image_height, Image.INTERPOLATE_BILINEAR)
	
	# 不同图片拼合在一起需要确定格式一致
	front.convert(Image.FORMAT_RGB8)
	back.convert(Image.FORMAT_RGB8)
	
	combined_image.blit_rect(front, Rect2(0, 0, front.get_width(), front.get_height()), Vector2(image_width, offset_y))
	combined_image.blit_rect(back, Rect2(0, 0, back.get_width(), back.get_height()), Vector2(0, offset_y))
	
	# 保存合并后的图片（调试用）
	#combined_image.save_jpg("F:\\" + str(randi() % 1000) + ".jpg")
	
	combined_image.generate_mipmaps()
	
	var res = ImageTexture.create_from_image(combined_image)
	return res
