@tool
extends Node2D

var _columns: int = 18
var _rows: int = 13
var _texture: Texture2D = preload("res://assets/classic_map.jpg")
var _road_texture: Texture2D = preload("res://assets/road.jpg")
var _river_texture: Texture2D = preload("res://assets/robot.jpg")
var _river_top_texture: Texture2D = preload("res://assets/robot.jpg")
var _river_bottom_texture: Texture2D = preload("res://assets/robot.jpg")
var _bridge_center_texture: Texture2D = preload("res://assets/robot.jpg")
var _bridge_top_texture: Texture2D = preload("res://assets/robot.jpg")
var _bridge_bottom_texture: Texture2D = preload("res://assets/robot.jpg")
var _dam_center_texture: Texture2D = preload("res://assets/robot.jpg")
var _dam_top_texture: Texture2D = preload("res://assets/robot.jpg")
var _dam_top_top_texture: Texture2D = preload("res://assets/robot.jpg")
var _dam_bottom_texture: Texture2D = preload("res://assets/robot.jpg")
var _dam_bottom_bottom_texture: Texture2D = preload("res://assets/robot.jpg")

var _cell_size: Vector2 = Vector2.ZERO
var _map_size: Vector2 = Vector2.ZERO
var _tile_overrides: Dictionary = {}

const TILE_ROAD := "road"
const TILE_RIVER_MAIN := "river_main"
const TILE_RIVER_TOP := "river_top"
const TILE_RIVER_BOTTOM := "river_bottom"
const TILE_BRIDGE_CENTER := "bridge_center"
const TILE_BRIDGE_TOP := "bridge_top"
const TILE_BRIDGE_BOTTOM := "bridge_bottom"
const TILE_DAM_CENTER := "dam_center"
const TILE_DAM_TOP := "dam_top"
const TILE_DAM_TOP_TOP := "dam_top_top"
const TILE_DAM_BOTTOM := "dam_bottom"
const TILE_DAM_BOTTOM_BOTTOM := "dam_bottom_bottom"

@export_range(1, 256, 1) var columns: int:
	get:
		return _columns
	set(value):
		value = max(1, value)
		if value == _columns:
			return
		_columns = value
		_rebuild_path()
		_recalculate()

@export_range(1, 256, 1) var rows: int:
	get:
		return _rows
	set(value):
		value = max(1, value)
		if value == _rows:
			return
		_rows = value
		_rebuild_path()
		_recalculate()

@export var texture: Texture2D:
	get:
		return _texture
	set(value):
		if value == _texture:
			return
		_texture = value
		_recalculate()

@export var road_texture: Texture2D:
	get:
		return _road_texture
	set(value):
		if value == _road_texture:
			return
		_road_texture = value
		queue_redraw()

@export var river_texture: Texture2D:
	get:
		return _river_texture
	set(value):
		if value == _river_texture:
			return
		_river_texture = value
		queue_redraw()

@export var river_top_texture: Texture2D:
	get:
		return _river_top_texture
	set(value):
		if value == _river_top_texture:
			return
		_river_top_texture = value
		queue_redraw()

@export var river_bottom_texture: Texture2D:
	get:
		return _river_bottom_texture
	set(value):
		if value == _river_bottom_texture:
			return
		_river_bottom_texture = value
		queue_redraw()

@export var bridge_center_texture: Texture2D:
	get:
		return _bridge_center_texture
	set(value):
		if value == _bridge_center_texture:
			return
		_bridge_center_texture = value
		queue_redraw()

@export var bridge_top_texture: Texture2D:
	get:
		return _bridge_top_texture
	set(value):
		if value == _bridge_top_texture:
			return
		_bridge_top_texture = value
		queue_redraw()

@export var bridge_bottom_texture: Texture2D:
	get:
		return _bridge_bottom_texture
	set(value):
		if value == _bridge_bottom_texture:
			return
		_bridge_bottom_texture = value
		queue_redraw()

@export var dam_center_texture: Texture2D:
	get:
		return _dam_center_texture
	set(value):
		if value == _dam_center_texture:
			return
		_dam_center_texture = value
		queue_redraw()

@export var dam_top_texture: Texture2D:
	get:
		return _dam_top_texture
	set(value):
		if value == _dam_top_texture:
			return
		_dam_top_texture = value
		queue_redraw()

@export var dam_top_top_texture: Texture2D:
	get:
		return _dam_top_top_texture
	set(value):
		if value == _dam_top_top_texture:
			return
		_dam_top_top_texture = value
		queue_redraw()

@export var dam_bottom_texture: Texture2D:
	get:
		return _dam_bottom_texture
	set(value):
		if value == _dam_bottom_texture:
			return
		_dam_bottom_texture = value
		queue_redraw()

@export var dam_bottom_bottom_texture: Texture2D:
	get:
		return _dam_bottom_bottom_texture
	set(value):
		if value == _dam_bottom_bottom_texture:
			return
		_dam_bottom_bottom_texture = value
		queue_redraw()

var _show_grid := true
@export var show_grid := true:
	set(value):
		if value == _show_grid:
			return
		_show_grid = value
		queue_redraw()
	get:
		return _show_grid

var _grid_line_width := 1.5
@export_range(0.5, 8.0, 0.5) var grid_line_width := 1.5:
	set(value):
		value = clamp(value, 0.5, 8.0)
		if value == _grid_line_width:
			return
		_grid_line_width = value
		queue_redraw()
	get:
		return _grid_line_width

var _grid_color := Color(0.95, 0.9, 0.6, 0.65)
@export var grid_color := Color(0.95, 0.9, 0.6, 0.65):
	set(value):
		if value == _grid_color:
			return
		_grid_color = value
		queue_redraw()
	get:
		return _grid_color

func _ready() -> void:
	_rebuild_path()
	_recalculate()

func _recalculate() -> void:
	if _texture == null or _columns <= 0 or _rows <= 0:
		_cell_size = Vector2.ZERO
		_map_size = Vector2.ZERO
	else:
		_cell_size = _texture.get_size()
		_map_size = Vector2(_cell_size.x * _columns, _cell_size.y * _rows)
	queue_redraw()

func _draw() -> void:
	if _texture == null or _map_size == Vector2.ZERO:
		return
	for x in range(_columns):
		for y in range(_rows):
			var pos := Vector2(x, y) * _cell_size
			var tex := _get_tile_texture(Vector2i(x, y))
			if tex == null:
				continue
			draw_texture_rect(tex, Rect2(pos, _cell_size), false)

	if _show_grid:
		_draw_grid_lines()

func _draw_grid_lines() -> void:
	var w := _grid_line_width
	for x in range(_columns + 1):
		var x_pos := x * _cell_size.x
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, _map_size.y), _grid_color, w)

	for y in range(_rows + 1):
		var y_pos := y * _cell_size.y
		draw_line(Vector2(0, y_pos), Vector2(_map_size.x, y_pos), _grid_color, w)

func get_cell_center(coords: Vector2i) -> Vector2:
	return Vector2(coords.x + 0.5, coords.y + 0.5) * _cell_size

func get_cell_size() -> Vector2:
	return _cell_size

func get_map_size() -> Vector2:
	return _map_size

func _get_tile_texture(grid_coords: Vector2i) -> Texture2D:
	if _tile_overrides.has(grid_coords):
		return _resolve_tile_texture(_tile_overrides[grid_coords])
	return _texture

func _resolve_tile_texture(tile_type: String) -> Texture2D:
	match tile_type:
		TILE_ROAD:
			return _road_texture
		TILE_RIVER_MAIN:
			return _river_texture
		TILE_RIVER_TOP:
			return _river_top_texture
		TILE_RIVER_BOTTOM:
			return _river_bottom_texture
		TILE_BRIDGE_CENTER:
			return _bridge_center_texture
		TILE_BRIDGE_TOP:
			return _bridge_top_texture
		TILE_BRIDGE_BOTTOM:
			return _bridge_bottom_texture
		TILE_DAM_CENTER:
			return _dam_center_texture
		TILE_DAM_TOP:
			return _dam_top_texture
		TILE_DAM_TOP_TOP:
			return _dam_top_top_texture
		TILE_DAM_BOTTOM:
			return _dam_bottom_texture
		TILE_DAM_BOTTOM_BOTTOM:
			return _dam_bottom_bottom_texture
		_:
			return _texture

func _rebuild_path() -> void:
	_road_tiles.clear()
	if _columns <= 0 or _rows <= 0:
		return

	var checkpoints := [
		Vector2i(2, 2),
		Vector2i(17, 2),
		Vector2i(17, 4),
		Vector2i(2, 4),
		Vector2i(2, 6),
		Vector2i(17, 6),
		Vector2i(17, 10),
		Vector2i(2, 10),
		Vector2i(2, 12),
		Vector2i(17, 12),
	]

	if checkpoints.is_empty():
		return

	var current: Vector2i = checkpoints[0]
	_store_user_cell(current)

	for i in range(1, checkpoints.size()):
		var target: Vector2i = checkpoints[i]
		while current != target:
			var step := _step_towards(current, target)
			if step == Vector2i.ZERO:
				break
			current += step
			_store_user_cell(current)

	queue_redraw()

func _store_user_cell(user_coord: Vector2i) -> void:
	if user_coord.x < 1 or user_coord.x > _columns:
		return
	if user_coord.y < 1 or user_coord.y > _rows:
		return

	var grid := Vector2i(user_coord.x - 1, _rows - user_coord.y)
	_road_tiles[grid] = true

func _step_towards(current: Vector2i, target: Vector2i) -> Vector2i:
	var dx := target.x - current.x
	var dy := target.y - current.y
	return Vector2i(_sign_int(dx), _sign_int(dy))

func _sign_int(value: int) -> int:
	if value == 0:
		return 0
	return value / abs(value)
