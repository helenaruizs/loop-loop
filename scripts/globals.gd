extends Node


signal start_game
signal level_completed(index: int)

enum ColorNames {
	COLOR_01,
	COLOR_02,
	COLOR_03,
	COLOR_04,
	COLOR_05,
	COLOR_06,
	COLOR_07,
	COLOR_08,
}

@export var color_01: Color
@export var color_02: Color
@export var color_03: Color
@export var color_04: Color

@export var bg_color_01: Color
@export var bg_color_02: Color
@export var bg_color_03: Color
@export var bg_color_04: Color

@export var hl_color_01: Color
@export var hl_color_02: Color
@export var hl_color_03: Color
@export var hl_color_04: Color

var colors: Array[Color] = []

var hl_colors: Array[Color] = []

var bg_colors: Array[Color] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	colors = [
		Globals.color_01,
		Globals.color_02,
		Globals.color_03,
		Globals.color_04,	
	]

	hl_colors = [
		Globals.hl_color_01,
		Globals.hl_color_02,
		Globals.hl_color_03,
		Globals.hl_color_04,	
	]

	bg_colors = [
		Globals.bg_color_01,
		Globals.bg_color_02,
		Globals.bg_color_03,
		Globals.bg_color_04,	
	]



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
