extends Node

var current_scene: Node = null
var level_index := 0
var levels := [
	"res://levels/main.tscn",
	# Add more levels here
]

func _ready() -> void:
	Globals.start_game.connect(start_game)
	show_title_screen()

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
	level_index += 1
	load_level(level_index)

func level_failed() -> void:
	load_level(level_index) # Restart same level

func show_thank_you_screen() -> void:
	change_scene("res://scenes/ThankYou.tscn")

func change_scene(path: String) -> void:
	# Remove all children (i.e., all screens) before adding the new one
	for child in get_children():
		child.queue_free()
	current_scene = null

	# Add new screen as child
	var new_scene: Node = load(path).instantiate()
	add_child(new_scene)
	current_scene = new_scene
