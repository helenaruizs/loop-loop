extends Node

@onready var timer: Timer = $Timer
@onready var fx_click: AudioStreamPlayer = $FX_Click
@onready var fx_click_2: AudioStreamPlayer = $FX_Click2
@onready var ui: Control = $UI

@export var characters: Array[Character]
@export var map: Map

var current_char : Character
var current_index := 0

@export var max_time := 4
var current_time := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	if characters.size() == 0:
		push_error("Characters array is empty")
	current_char = characters[0]

func _physics_process(delta: float) -> void:
	current_char.char_physics_process(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_character_turn_done() -> void:
	current_index = (current_index + 1) % characters.size()
	current_char = characters[current_index]

func _on_timer_timeout() -> void:
	current_time += 1
	if current_time != max_time:
		fx_click.play()
	ui.update_timer_counter(current_time)
	if current_time == max_time:
		new_turn()
		current_time = 0

func new_turn() -> void:
	
	fx_click_2.play()
	
	# Cycle through to next char in the array and make it their turn
	current_index = (current_index + 1) % characters.size()
	current_char = characters[current_index]
