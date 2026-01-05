@tool
extends Node2D

var _columns: int = 18
var _rows: int = 13
var _texture: Texture2D = null
var _road_left_to_right_texture: Texture2D = preload("res://assets/RoadLeft-Right.png")
var _road_right_to_left_texture: Texture2D = preload("res://assets/RoadRight-Left.png")
var _road_vertical_texture: Texture2D = preload("res://assets/RoadUp.png")
var _river_texture: Texture2D = preload("res://assets/robot.jpg")
var _river_top_texture: Texture2D = preload("res://assets/robot.jpg")
var _river_bottom_texture: Texture2D = preload("res://assets/robot.jpg")
var _bridge_center_texture: Texture2D = preload("res://assets/robot.jpg")
var _bridge_top_texture: Texture2D = preload("res://assets/robot.jpg")
var _bridge_bottom_texture: Texture2D = preload("res://assets/robot.jpg")
var _dam_full_texture: Texture2D = preload("res://assets/dump.png")
var _angle_right_bottom_texture: Texture2D = preload("res://assets/robot.jpg")
var _angle_left_top_texture: Texture2D = preload("res://assets/robot.jpg")
var _snow_left_texture: Texture2D = preload("res://assets/robot.jpg")
var _snow_top_texture: Texture2D = preload("res://assets/robot.jpg")
var _snow_right_texture: Texture2D = preload("res://assets/robot.jpg")
var _snow_bottom_texture: Texture2D = preload("res://assets/robot.jpg")
var _tree_texture: Texture2D = preload("res://assets/elka.png")

var _cell_size: Vector2 = Vector2.ZERO
var _map_size: Vector2 = Vector2.ZERO
var _tile_overrides: Dictionary = {}
var _composite_tiles: Array = []

const TILE_ROAD_LEFT_TO_RIGHT := "road_left_to_right"
const TILE_ROAD_RIGHT_TO_LEFT := "road_right_to_left"
const TILE_ROAD_VERTICAL := "road_vertical"
const TILE_RIVER_MAIN := "river_main"
const TILE_RIVER_TOP := "river_top"
const TILE_RIVER_BOTTOM := "river_bottom"
const TILE_BRIDGE_CENTER := "bridge_center"
const TILE_BRIDGE_TOP := "bridge_top"
const TILE_BRIDGE_BOTTOM := "bridge_bottom"
const TILE_DAM_FULL := "dam_full"
const TILE_ANGLE_RIGHT_BOTTOM := "angle_right_bottom"
const TILE_ANGLE_LEFT_TOP := "angle_left_top"
const TILE_SNOW_LEFT := "snow_left"
const TILE_SNOW_TOP := "snow_top"
const TILE_SNOW_RIGHT := "snow_right"
const TILE_SNOW_BOTTOM := "snow_bottom"

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

@export var road_left_to_right_texture: Texture2D:
	get:
		return _road_left_to_right_texture
	set(value):
		if value == _road_left_to_right_texture:
			return
		_road_left_to_right_texture = value
		queue_redraw()

@export var road_right_to_left_texture: Texture2D:
	get:
		return _road_right_to_left_texture
	set(value):
		if value == _road_right_to_left_texture:
			return
		_road_right_to_left_texture = value
		queue_redraw()

@export var road_vertical_texture: Texture2D:
	get:
		return _road_vertical_texture
	set(value):
		if value == _road_vertical_texture:
			return
		_road_vertical_texture = value
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

@export var dam_full_texture: Texture2D:
	get:
		return _dam_full_texture
	set(value):
		if value == _dam_full_texture:
			return
		_dam_full_texture = value
		queue_redraw()

@export var angle_right_bottom_texture: Texture2D:
	get:
		return _angle_right_bottom_texture
	set(value):
		if value == _angle_right_bottom_texture:
			return
		_angle_right_bottom_texture = value
		queue_redraw()

@export var angle_left_top_texture: Texture2D:
	get:
		return _angle_left_top_texture
	set(value):
		if value == _angle_left_top_texture:
			return
		_angle_left_top_texture = value
		queue_redraw()

@export var snow_left_texture: Texture2D:
	get:
		return _snow_left_texture
	set(value):
		if value == _snow_left_texture:
			return
		_snow_left_texture = value
		queue_redraw()

@export var snow_top_texture: Texture2D:
	get:
		return _snow_top_texture
	set(value):
		if value == _snow_top_texture:
			return
		_snow_top_texture = value
		queue_redraw()

@export var snow_right_texture: Texture2D:
	get:
		return _snow_right_texture
	set(value):
		if value == _snow_right_texture:
			return
		_snow_right_texture = value
		queue_redraw()

@export var snow_bottom_texture: Texture2D:
	get:
		return _snow_bottom_texture
	set(value):
		if value == _snow_bottom_texture:
			return
		_snow_bottom_texture = value
		queue_redraw()

@export var tree_texture: Texture2D:
	get:
		return _tree_texture
	set(value):
		if value == _tree_texture:
			return
		_tree_texture = value
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
	var reference_tile := _get_reference_tile_texture()
	if _columns <= 0 or _rows <= 0:
		_cell_size = Vector2.ZERO
		_map_size = Vector2.ZERO
	else:
		if reference_tile != null:
			_cell_size = reference_tile.get_size()
		elif _texture != null:
			var texture_size := _texture.get_size()
			_cell_size = Vector2(
				texture_size.x / float(_columns),
				texture_size.y / float(_rows)
			)
		else:
			_cell_size = Vector2.ZERO
		_map_size = Vector2(_cell_size.x * _columns, _cell_size.y * _rows) if _cell_size != Vector2.ZERO else Vector2.ZERO
	queue_redraw()

func _get_reference_tile_texture() -> Texture2D:
	var candidates := [
		_road_left_to_right_texture,
		_road_right_to_left_texture,
		_road_vertical_texture,
		_river_texture,
		_river_top_texture,
		_river_bottom_texture,
		_bridge_center_texture,
		_bridge_top_texture,
		_bridge_bottom_texture,
		_dam_full_texture,
		_angle_right_bottom_texture,
		_angle_left_top_texture,
		_snow_left_texture,
		_snow_top_texture,
		_snow_right_texture,
		_snow_bottom_texture,
		_tree_texture
	]
	for tex in candidates:
		if tex != null:
			return tex
	return null

func _draw() -> void:
	if _cell_size == Vector2.ZERO or _map_size == Vector2.ZERO:
		return

	var use_texture_atlas := false
	var atlas_region_size := Vector2.ZERO
	if _texture != null:
		var texture_size := _texture.get_size()
		if _map_size != Vector2.ZERO \
		and is_equal_approx(texture_size.x, _map_size.x) \
		and is_equal_approx(texture_size.y, _map_size.y):
			use_texture_atlas = true
			atlas_region_size = Vector2(
				texture_size.x / float(max(1, _columns)),
				texture_size.y / float(max(1, _rows))
			)

	for x in range(_columns):
		for y in range(_rows):
			if _texture != null:
				var base_pos := Vector2(x, y) * _cell_size
				if use_texture_atlas:
					var region_pos := Vector2(x, y) * atlas_region_size
					var region_rect := Rect2(region_pos, atlas_region_size)
					draw_texture_rect_region(_texture, Rect2(base_pos, _cell_size), region_rect)
				else:
					draw_texture_rect(_texture, Rect2(base_pos, _cell_size), false)

			var tex := _get_tile_texture(Vector2i(x, y))
			if tex == null:
				continue
			var pos := Vector2(x, y) * _cell_size
			draw_texture_rect(tex, Rect2(pos, _cell_size), false)

	for composite in _composite_tiles:
		var tex: Texture2D = composite.get("texture")
		if tex == null:
			continue
		var origin: Vector2i = composite.get("origin")
		var size: Vector2i = composite.get("size")
		var pos := Vector2(origin.x, origin.y) * _cell_size
		var rect_size := Vector2(size.x, size.y) * _cell_size
		draw_texture_rect(tex, Rect2(pos, rect_size), false)

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
	return null

func _resolve_tile_texture(tile_type: String) -> Texture2D:
	match tile_type:
		TILE_ROAD_LEFT_TO_RIGHT:
			return _road_left_to_right_texture
		TILE_ROAD_RIGHT_TO_LEFT:
			return _road_right_to_left_texture
		TILE_ROAD_VERTICAL:
			return _road_vertical_texture
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
		TILE_DAM_FULL:
			return _dam_full_texture
		TILE_ANGLE_RIGHT_BOTTOM:
			return _angle_right_bottom_texture
		TILE_ANGLE_LEFT_TOP:
			return _angle_left_top_texture
		TILE_SNOW_LEFT:
			return _snow_left_texture
		TILE_SNOW_TOP:
			return _snow_top_texture
		TILE_SNOW_RIGHT:
			return _snow_right_texture
		TILE_SNOW_BOTTOM:
			return _snow_bottom_texture
		_:
			return _texture

func _rebuild_path() -> void:
	_tile_overrides.clear()
	_composite_tiles.clear()
	if _columns <= 0 or _rows <= 0:
		return

	_build_road_path()
	_build_river()
	_place_structures()

	queue_redraw()

func _build_road_path() -> void:
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
	var initial_step := Vector2i.ZERO
	if checkpoints.size() > 1:
		initial_step = _step_towards(current, checkpoints[1])
	_store_tile(current, _road_tile_for_step(initial_step))

	for i in range(1, checkpoints.size()):
		var target: Vector2i = checkpoints[i]
		while current != target:
			var step := _step_towards(current, target)
			if step == Vector2i.ZERO:
				break
			current += step
			_store_tile(current, _road_tile_for_step(step))

func _build_river() -> void:
	_fill_horizontal_line(2, 16, 8, TILE_RIVER_MAIN)
	_fill_horizontal_line(2, 16, 9, TILE_RIVER_TOP)
	_fill_horizontal_line(2, 16, 7, TILE_RIVER_BOTTOM)

	_store_tile(Vector2i(17, 8), TILE_BRIDGE_CENTER)
	_store_tile(Vector2i(17, 9), TILE_BRIDGE_TOP)
	_store_tile(Vector2i(17, 7), TILE_BRIDGE_BOTTOM)

	var dam_bottom_cell := 6
	var dam_height := 5
	var dam_top_cell: int = min(_rows, dam_bottom_cell + dam_height - 1)
	_add_composite_tile(Vector2i(1, dam_top_cell), Vector2i(1, dam_height), _dam_full_texture)

func _place_structures() -> void:
	_store_tile(Vector2i(18, 1), TILE_ANGLE_RIGHT_BOTTOM)
	_store_tile(Vector2i(1, 13), TILE_ANGLE_LEFT_TOP)

	_store_tiles([
		Vector2i(1, 3),
		Vector2i(1, 4),
		Vector2i(1, 5),
		Vector2i(1, 11),
		Vector2i(1, 12),
	], TILE_SNOW_LEFT)

	_fill_horizontal_line(2, 16, 13, TILE_SNOW_TOP)
	_fill_vertical_line(18, 2, 11, TILE_SNOW_RIGHT)
	_fill_horizontal_line(3, 17, 1, TILE_SNOW_BOTTOM)

	var tree_base_cell := Vector2i(
		max(1, _columns - 1),
		max(1, _rows - 1)
	)
	var tree_top_cell := Vector2i(
		tree_base_cell.x,
		min(_rows, tree_base_cell.y + 1)
	)
	_add_composite_tile(tree_top_cell, Vector2i(1, 2), _tree_texture)

func _store_tile(user_coord: Vector2i, tile_type: String) -> void:
	if user_coord.x < 1 or user_coord.x > _columns:
		return
	if user_coord.y < 1 or user_coord.y > _rows:
		return

	var grid := _user_to_grid(user_coord)
	_tile_overrides[grid] = tile_type

func _fill_horizontal_line(from_x: int, to_x: int, y: int, tile_type: String) -> void:
	var start_x: int = min(from_x, to_x)
	var end_x: int = max(from_x, to_x)
	for x in range(start_x, end_x + 1):
		_store_tile(Vector2i(x, y), tile_type)

func _fill_vertical_line(x: int, from_y: int, to_y: int, tile_type: String) -> void:
	var start_y: int = min(from_y, to_y)
	var end_y: int = max(from_y, to_y)
	for y in range(start_y, end_y + 1):
		_store_tile(Vector2i(x, y), tile_type)

func _store_tiles(coords: Array, tile_type: String) -> void:
	for coord in coords:
		if coord is Vector2i:
			_store_tile(coord, tile_type)

func _add_composite_tile(top_left_user: Vector2i, size_in_cells: Vector2i, texture: Texture2D) -> void:
	if texture == null:
		return
	var grid_origin := _user_to_grid(top_left_user)
	_composite_tiles.append({
		"origin": grid_origin,
		"size": size_in_cells,
		"texture": texture
	})

func _user_to_grid(user_coord: Vector2i) -> Vector2i:
	return Vector2i(user_coord.x - 1, _rows - user_coord.y)

func _road_tile_for_step(step: Vector2i) -> String:
	if step.x > 0:
		return TILE_ROAD_LEFT_TO_RIGHT
	if step.x < 0:
		return TILE_ROAD_RIGHT_TO_LEFT
	if step.y != 0:
		return TILE_ROAD_VERTICAL
	return TILE_ROAD_LEFT_TO_RIGHT

func _step_towards(current: Vector2i, target: Vector2i) -> Vector2i:
	if current.x != target.x:
		return Vector2i(_sign_int(target.x - current.x), 0)
	if current.y != target.y:
		return Vector2i(0, _sign_int(target.y - current.y))
	return Vector2i.ZERO

func _sign_int(value: int) -> int:
	if value == 0:
		return 0
	return value / abs(value)
