class_name SpawnPoint

extends Node2D

enum CharType {
	FTUE,
	EASY,
	NORMAL,
	HARD,
}

const ftue_char = preload("uid://b187ae6qhloof")
const easy_char = preload("uid://bf0q7o618c3c6")
const normal_char = preload("uid://b8ml3toppckaw")

@export var char_type: CharType

func get_char_scene() -> PackedScene:
	match char_type:
		CharType.FTUE:
			return ftue_char
		CharType.EASY:
			return easy_char
		CharType.NORMAL:
			return normal_char
		_:
			return
