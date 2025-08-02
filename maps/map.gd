class_name Map

extends Node2D

const TILEMARKER = preload("uid://b58a0d4wqwnwj")

@onready var tilemap: TileMapLayer = $TileMapLayer
var tile_markers: Array[TileMarker] = []

var tile_size: Vector2

### Objectives
var objectives_color_01: Array[TileMarker] =[]
var objectives_color_02: Array[TileMarker] =[]
var objectives_color_03: Array[TileMarker] =[]
var objectives_color_04: Array[TileMarker] =[]

### Objectives
var objectives_color_01_hits: Array[TileMarker] =[]
var objectives_color_02_hits: Array[TileMarker] =[]
var objectives_color_03_hits: Array[TileMarker] =[]
var objectives_color_04_hits: Array[TileMarker] =[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_size = tilemap.tile_set.tile_size
	_spawn_tile_markers()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if objectives_color_01.size() == objectives_color_01_hits.size() and objectives_color_02.size() == objectives_color_02_hits.size():
		print("BOOM")
		Globals.emit_signal("level_completed")

func _spawn_tile_markers() -> void:
	tile_markers.clear()
	for cell: Vector2i in tilemap.get_used_cells():
		var placed_marker: TileMarker = get_marker_at_cell(cell)
		if placed_marker != null:
			match placed_marker.objective_color:
				Globals.ColorNames.COLOR_01:
					objectives_color_01.append(placed_marker)
				Globals.ColorNames.COLOR_02:
					objectives_color_02.append(placed_marker)
				Globals.ColorNames.COLOR_03:
					objectives_color_03.append(placed_marker)
				Globals.ColorNames.COLOR_04:
					objectives_color_04.append(placed_marker)
			placed_marker.objective_triggered_on.connect(_on_marker_triggered)  # Skip if marker is already there
			placed_marker.objective_triggered_off.connect(_on_marker_triggered_out)
		# 1) Instance the marker
		var marker: TileMarker = TILEMARKER.instantiate() as TileMarker

		# 2) Compute the world‐space center of that cell
		var local_pos: Vector2  = tilemap.map_to_local(cell)
		marker.position.y        = local_pos.y + tile_size.y/2
		marker.position.x        = local_pos.x - tile_size.x/2

		# 3) Parent under this Map and track it
		add_child(marker)
		tile_markers.append(marker)
		
func get_marker_at_cell(cell: Vector2i) -> TileMarker:
	var local_pos: Vector2 = tilemap.map_to_local(cell)
	var marker_center := Vector2(
		local_pos.x - tile_size.x/2,
		local_pos.y + tile_size.y/2
	)
	for child in get_children():
		if child is TileMarker:
			if child.position.distance_to(marker_center) < 1.0:
				return child as TileMarker
	return null


func _on_marker_triggered(marker: TileMarker, color: Globals.ColorNames) -> void:
	#if not objectives_color_01_hits.has(marker) or not objectives_color_02_hits.has(marker):
		#marker.play_blink_in()
	match color:
		Globals.ColorNames.COLOR_01:
			objectives_color_01_hits.append(marker)
		Globals.ColorNames.COLOR_02:
			objectives_color_02_hits.append(marker)
		Globals.ColorNames.COLOR_03:
			objectives_color_03_hits.append(marker)
		Globals.ColorNames.COLOR_04:
			objectives_color_04_hits.append(marker)
	
	if objectives_color_01.size() == objectives_color_01_hits.size() and objectives_color_02.size() == objectives_color_02_hits.size():
		print("BOOM")
		Globals.emit_signal("level_completed")
	print(objectives_color_01_hits.size())
	print(objectives_color_01.size())
	
func _on_marker_triggered_out(marker: TileMarker, color: Globals.ColorNames) -> void:
	#if objectives_color_01_hits.has(marker) or objectives_color_02_hits.has(marker):
		#marker.play_blink_out()
	match color:
		Globals.ColorNames.COLOR_01:
			objectives_color_01_hits.erase(marker)
		Globals.ColorNames.COLOR_02:
			objectives_color_02_hits.erase(marker)
		Globals.ColorNames.COLOR_03:
			objectives_color_03_hits.erase(marker)
		Globals.ColorNames.COLOR_04:
			objectives_color_04_hits.erase(marker)

func compare_arrays(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	var a_sorted: Array = a.duplicate()
	var b_sorted: Array  = b.duplicate()
	a_sorted.sort() # sorts by object id
	b_sorted.sort()
	return a_sorted == b_sorted
