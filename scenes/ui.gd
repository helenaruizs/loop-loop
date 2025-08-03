class_name UI

extends Control
@onready var timer_counter: Label = $TimerCounter
@onready var bg: ColorRect = $ColorRect
@onready var pause_menu: Control = $PauseMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.pause.connect(on_pause)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_timer_counter(_current_time: int) -> void:
	timer_counter.text = str(_current_time)

func on_pause(is_paused: bool) -> void:
	pause_menu.view_pause_menu(is_paused)
