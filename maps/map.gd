class_name Map

extends Node2D

const TILEMARKER = preload("uid://b58a0d4wqwnwj")

@onready var tilemap: TileMapLayer = $TileMapLayer
var tile_markers: Array[TileMarker] = []

var tile_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_size = tilemap.tile_set.tile_size
	_spawn_tile_markers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _spawn_tile_markers() -> void:
	tile_markers.clear()
	for cell: Vector2i in tilemap.get_used_cells():
		if _has_marker_at_cell(cell):
			continue  # Skip if marker is already there
		# 1) Instance the marker
		var marker: TileMarker = TILEMARKER.instantiate() as TileMarker

		# 2) Compute the world‐space center of that cell
		var local_pos: Vector2  = tilemap.map_to_local(cell)
		marker.position.y        = local_pos.y + tile_size.y/2
		marker.position.x        = local_pos.x - tile_size.x/2

		# 3) Parent under this Map and track it
		add_child(marker)
		tile_markers.append(marker)
		
func _has_marker_at_cell(cell: Vector2i) -> bool:
	var local_pos: Vector2 = tilemap.map_to_local(cell)
	var marker_center := Vector2(
		local_pos.x - tile_size.x/2,
		local_pos.y + tile_size.y/2
	)
	for child in get_children():
		if child is TileMarker:
			if child.position.distance_to(marker_center) < 1.0:
				return true
	return false
