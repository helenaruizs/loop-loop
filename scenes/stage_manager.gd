extends Node

var level_index: int = 0


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var levels_array: Array[PackedScene]
@export var scenes: Array[PackedScene]

var levels := [
	"res://levels/main.tscn",
	"res://levels/level01.tscn",
]

func _ready() -> void:
	if Globals.has_signal("start_game"):
		Globals.start_game.connect(start_game)
	if Globals.has_signal("restart_level"):
		Globals.restart_level.connect(restart_level)
	Globals.level_completed.connect(level_complete)
	Globals.quit_game.connect(on_quit_game)

	show_title_screen(scenes[0])


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		Globals.pause.emit(get_tree().paused)
	if event.is_action_pressed("restart_level"):
		restart_level()
	#
#func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("DEBUG_LEVEL_COMPLETE"):
		#level_complete()

func show_title_screen(scene: PackedScene) -> void:
	change_scene(scene)

func start_game() -> void:
	level_index = 0
	load_level(level_index)

func load_level(index: int) -> void:
	if index >= levels_array.size():
		show_thank_you_screen(scenes[2])
	else:
		change_scene(levels_array[index])

func level_complete() -> void:
	get_tree().paused = true
	audio_stream_player.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().paused = false
	level_index += 1
	ScreenTransition._play_wipe_out()
	load_level(level_index)

func level_failed() -> void:
	load_level(level_index)

func show_thank_you_screen(scene: PackedScene) -> void:
	change_scene(scene)

func restart_level() -> void:
	if get_tree().paused:
		get_tree().paused = not get_tree().paused
	load_level(level_index)

func change_scene(scene: PackedScene) -> void:
	var err: = get_tree().change_scene_to_packed(scene)
	if err != OK:
		push_error("StageManager: ERROR! Could not change scene to: %s" % scene)
	else:
		print("StageManager: Scene changed to:", scene)

func on_quit_game() -> void:
	get_tree().quit()
