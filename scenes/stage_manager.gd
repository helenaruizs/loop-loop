extends Node

var level_index: int = 0

var levels := [
	"res://levels/main.tscn"
	# Add more levels as needed!
]

func _ready() -> void:
	print("StageManager: _ready() called")
	# Connect global signals if you use them
	if Globals.has_signal("start_game"):
		Globals.start_game.connect(start_game)
		print("StageManager: Connected to Globals.start_game")
	if Globals.has_signal("restart_level"):
		Globals.restart_level.connect(restart_level)
		print("StageManager: Connected to Globals.restart_level")
	# Add more connections as needed

	show_title_screen()

func show_title_screen() -> void:
	print("StageManager: Showing Title Screen")
	change_scene("res://scenes/title.tscn")

func start_game() -> void:
	print("StageManager: Starting game")
	level_index = 0
	load_level(level_index)

func load_level(index: int) -> void:
	print("StageManager: Loading level", index)
	if index >= levels.size():
		show_thank_you_screen()
	else:
		change_scene(levels[index])

func level_complete() -> void:
	print("StageManager: Level complete")
	level_index += 1
	load_level(level_index)

func level_failed() -> void:
	print("StageManager: Level failed, reloading level", level_index)
	load_level(level_index)

func show_thank_you_screen() -> void:
	print("StageManager: Showing Thank You screen")
	change_scene("res://scenes/ThankYou.tscn")

func restart_level() -> void:
	print("StageManager: Restarting current level", level_index)
	load_level(level_index)

func change_scene(path: String) -> void:
	print("StageManager: change_scene_to_file called with path:", path)
	var err: = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("StageManager: ERROR! Could not change scene to: %s" % path)
	else:
		print("StageManager: Scene changed to:", path)
