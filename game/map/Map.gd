extends Node

var tile_layers

export var tile_set: TileSet

onready var TileLayer0 = get_node("TileLayer0")
onready var TileLayer1 = get_node("TileLayer1")
onready var TileLayer2 = get_node("TileLayer2")
onready var TileLayer3 = get_node("TileLayer3")

const Packets = preload('res://network/Packets.gd')

func _ready():
	tile_layers = [TileLayer0, TileLayer1, TileLayer2, TileLayer3]
	
	Builder.set_tile_set(tile_set)
	Builder.build_tilesets()

func handle_region(data):
	var opcode = int(data.pop_front())
	var buffer_size = int(data.pop_front())
	var compressed_data = data.pop_front()
	
	if not compressed_data:
		print('[Error] No data received for the region.')
		return
		
	var byte_array = Marshalls.base64_to_raw(compressed_data)
	var decompressed_data = byte_array.decompress(buffer_size, File.COMPRESSION_GZIP)
	var info = JSON.parse(decompressed_data.get_string_from_utf8()).result
	
	match opcode:
		Packets.RegionOpcode.Render:
			print('Received render opcode.')
			
			for tile in info:
				handle_tile(tile)
			
		Packets.RegionOpcode.Tileset:
			print('Received tileset opcode.')
			for tile in info:
				handle_tileset(tile, info[tile])
	
func handle_tile(info):
	if not info or not 'data' in info:
		return
		
	var tile_data = info.data
	var position = info.position
	
	if typeof(tile_data) == TYPE_ARRAY:
		for i in range(0, len(tile_data)):
			set_tile(tile_layers[i], position.x, position.y, tile_data[i])
	else:
		set_tile(tile_layers[0], position.x, position.y, tile_data)
	
func handle_tileset(tile_id, info):
	tile_id = int(tile_id) - 1

	var coord = get_tile_coord(tile_id)
	var tileset_id = coord.tileset_id

	###
	# c - Full tile collision
	# p - Polygon partial tile collision
	# h - Tile with Z-Index Properties
	###

	if 'c' in info:
		if shape_exists(tileset_id, coord.x, coord.y):
			return
		
		var collision_shape = ConvexPolygonShape2D.new()

		collision_shape.set_point_cloud(get_rectangle_points())
		
		tile_set.tile_add_shape(tileset_id, collision_shape, Transform2D(), false, Vector2(coord.x, coord.y))

	if 'h' in info:
		tile_set.autotile_set_z_index(tileset_id, Vector2(coord.x, coord.y), info.h)

func set_tile(tile_layer, x, y, tile_id, animation = null):
	tile_id = int(tile_id) - 1
	
	var tile_info = get_tile_coord(tile_id)
	var tile_data = Vector2(tile_info.x, tile_info.y)
	
	tile_layer.set_cell(int(x), int(y), tile_info.tileset_id, false, false, false, tile_data)
	
func get_tile_coord(tile_id):
	var formatted_tile_id = tile_id
	var tileset_id

	for i in Builder.tilesheet_map:
		if tile_id < Builder.tilesheet_map[i]:
			if i > 0:
				if i in Builder.tilesheet_gaps:
					formatted_tile_id -= int(Builder.tilesheet_map[Builder.tilesheet_gaps[i]])
				else:
					formatted_tile_id -= int(Builder.tilesheet_map[i - 1])
				
			tileset_id = i
			break

	var dimensions = Builder.tilesheet_dimensions[tileset_id]
	
	var x = get_x(formatted_tile_id, dimensions.width)
	var y = floor(formatted_tile_id / dimensions.width)
	
	return {
		'x': x,
		'y': y,
		'tileset_id': tileset_id
	}

func get_x(index, size):
	if index == 0:
		return 0

	return index % size

func shape_exists(tileset_id, x, y):
	for info in tile_set.tile_get_shapes(tileset_id):
		if info.autotile_coord.x == x and info.autotile_coord.y == y:
			return true
	
	return false
	
func get_rectangle_points(size = 32):
	return [Vector2(0, 0), Vector2(size, 0), Vector2(size, size), Vector2(0, size)]
