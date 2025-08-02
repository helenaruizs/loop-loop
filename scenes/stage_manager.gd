extends Node

var level_index: int = 0

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

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
		Globals.level_completed.emit()
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
	audio_stream_player.play()
	#do_freeze_and_zoom_effect()
	# Show your freeze UI, play animation, whatever
	# After delay or player input, resume and switch
	await get_tree().create_timer(0.4).timeout
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


func do_freeze_and_zoom_effect() -> void:
	# 1. Take screenshot
	var img := get_viewport().get_texture().get_image()
	var tex := ImageTexture.create_from_image(img)
	# 2. Show it
	var pic := TextureRect.new()
	pic.texture = tex
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.anchor_left = 0
	pic.anchor_top = 0
	pic.anchor_right = 1
	pic.anchor_bottom = 1
	pic.offset_left = 0
	pic.offset_top = 0
	pic.offset_right = 0
	pic.offset_bottom = 0
	add_child(pic)
	# 3. Animate (zoom)
	pic.scale = Vector2.ONE
	pic.z_index = 500
	var tween := create_tween()
	tween.tween_property(pic, "scale", Vector2(1.05, 1.05), 0.5).set_trans(Tween.TRANS_SINE)
	# 4. Optionally remove after done
	await tween.finished
	pic.queue_free()
