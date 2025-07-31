class_name UI

extends Control
@onready var timer_counter: Label = $TimerCounter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_timer_counter(_current_time: int) -> void:
	timer_counter.text = str(_current_time)
