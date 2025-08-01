extends Node

@onready var main_light: DirectionalLight2D = $DirectionalLight2D

@onready var timer: Timer = $Timer
@onready var fx_click: AudioStreamPlayer = $FX_Click
@onready var fx_click_2: AudioStreamPlayer = $FX_Click2
@onready var camera: Camera2D = $Camera2D

@export var characters: Array[Character]
@export var ui: UI
@export var map: Map
@export var tempo: float = 0.5

var colors: Array[Color] = [
	Globals.color_01,
	Globals.color_02,
	Globals.color_03,
	Globals.color_04,	
]

var hl_colors: Array[Color] = [
	Globals.hl_color_01,
	Globals.hl_color_02,
	Globals.hl_color_03,
	Globals.hl_color_04,	
]

var current_char: Character
var current_color: Color
var current_index:= 0

@export var max_time := 4
var current_time := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	timer.wait_time = tempo
	if characters.size() == 0:
		push_error("Characters array is empty")
	for char: Character in characters:
		char.character_color = colors[characters.find(char)]
		char.hl_color = hl_colors[characters.find(char)]
		char.set_shader_colors(char.character_color, char.hl_color)
	current_char = characters[0]
	current_color = colors[0]
	current_char.set_shader_intensity(1.0)
	change_light(current_color)

func _physics_process(delta: float) -> void:
	current_char.char_physics_process(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	current_time += 1
	if current_time != max_time:
		fx_click.play()
		#ui.bg.update_bg_fx(0.4)
	ui.update_timer_counter(current_time)
	if current_time == max_time:
		new_turn()
		current_time = 0

func new_turn() -> void:
	
	fx_click_2.play()
	
	ui.bg.update_bg_fx(1.0)
	
	current_char.tween_shader(1.0, 0.0)
	current_char.animation_player.play("blink")
	# Cycle through to next char in the array and make it their turn
	current_index = (current_index + 1) % characters.size()
	current_char = characters[current_index]
	current_color = colors[current_index]	
	
	current_char.tween_shader(0.0, 1.0)
	
	change_light(current_color)


func tween_light() -> void:
	var tween: Tween = create_tween()
	var duration:= 0.3
	tween.tween_method(change_light, Color.WHITE, current_color, duration)

func change_light(_color: Color) -> void:
	main_light.color = _color
