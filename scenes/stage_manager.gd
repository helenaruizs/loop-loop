extends Node

var level_index: int = 0

var levels := [
	"res://levels/main.tscn",
	"res://levels/level01.tscn",
	# Add more levels as needed!
]

func _ready() -> void:
	# Connect global signals if you use them
	if Globals.has_signal("start_game"):
		Globals.start_game.connect(start_game)
	if Globals.has_signal("restart_level"):
		Globals.restart_level.connect(restart_level)
	Globals.level_completed.connect(level_complete)
	# Add more connections as needed

	show_title_screen()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("DEBUG_LEVEL_COMPLETE"):
		level_complete()

func show_title_screen() -> void:
	change_scene("res://scenes/title.tscn")

func start_game() -> void:
	level_index = 0
	load_level(level_index)

func load_level(index: int) -> void:
	if index >= levels.size():
		show_thank_you_screen()
	else:
		change_scene(levels[index])

func level_complete() -> void:
	get_tree().paused = true
	# Show your freeze UI, play animation, whatever
	# After delay or player input, resume and switch
	await get_tree().create_timer(0.6).timeout
	get_tree().paused = false
	level_index += 1
	load_level(level_index)

func level_failed() -> void:
	load_level(level_index)

func show_thank_you_screen() -> void:
	change_scene("res://scenes/ThankYou.tscn")

func restart_level() -> void:
	load_level(level_index)

func change_scene(path: String) -> void:
	var err: = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("StageManager: ERROR! Could not change scene to: %s" % path)
	else:
		print("StageManager: Scene changed to:", path)
