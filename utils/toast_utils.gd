extends Object
class_name ToastUtils

static func error(text, _pos = "C") -> void:

	ToastX.error(text)
		#"text": text,           # Text (emojis can be used)
		#"bgcolor": Color(1.0, 0.89, 0.0, 0.573),     # Background Color
		#"color": Color(1.0, 1.0, 1.0, 1.0),         # Text Color
		#"gravity": gravity,                   # top or bottom
		#"direction": direction,               # left or center or right
		#"text_size": 18,                    # [optional] Text (font) size // experimental (warning!)
		#"use_font": true                    # [optional] Use custom ToastParty font // experimental (warning!)

static func info(text, _pos = "TL") -> void:

	ToastX.info(text)
		#"text": text,           # Text (emojis can be used)
		#"bgcolor": Color(0.427, 0.851, 0.706, 0.573),     # Background Color
		#"color": Color(0.151, 0.151, 0.151, 1.0),         # Text Color
		#"gravity": gravity,                   # top or bottom
		#"direction": direction,               # left or center or right
		#"text_size": 18,                    # [optional] Text (font) size // experimental (warning!)
		#"use_font": true                    # [optional] Use custom ToastParty font // experimental (warning!)

static func warn(text, _pos = "T") -> void:

	ToastX.warning(text)
		#"text": text,           # Text (emojis can be used)
		#"bgcolor": Color(1.0, 0.647, 0.0, 0.573),     # Background Color
		#"color": Color(1.0, 1.0, 1.0, 1.0),         # Text Color
		#"gravity": gravity,                   # top or bottom
		#"direction": direction,               # left or center or right
		#"text_size": 18,                    # [optional] Text (font) size // experimental (warning!)
		#"use_font": true                    # [optional] Use custom ToastParty font // experimental (warning!)

static func success(text, _pos = "T") -> void:

	ToastX.success(text)
		#"text": text,           # Text (emojis can be used)
		#"bgcolor": Color(0.427, 0.851, 0.706, 0.573),     # Background Color
		#"color": Color(0.151, 0.151, 0.151, 1.0),         # Text Color
		#"gravity": gravity,                   # top or bottom
		#"direction": direction,               # left or center or right
		#"text_size": 18,                    # [optional] Text (font) size // experimental (warning!)
		#"use_font": true                    # [optional] Use custom ToastParty font // experimental (warning!)
