extends Node

var tilesheet_map = {}
var tilesheet_dimensions = {}
var tilesheet_gaps = {}

var tile_set: TileSet
var ready = false
var found_null = false

var texture_count = 0

func _ready():
	pass

func set_tile_set(new_tile_set):
	self.tile_set = new_tile_set
	self.texture_count = get_texture_count()
	
func build_tilesets():
	if not tile_set:
		return
	
	var tile_size = tile_set.autotile_get_size(0)
	
	if not tile_size:
		return
	
	ready = true
		
	tile_size = tile_size.x
	
	var last_tilesheet_id = 0
	
	for i in range(texture_count):
		var texture = tile_set.tile_get_texture(i)
		
		if not texture:
			continue
			
		var name = get_resource_name(texture.resource_path)
			
		if not 'tilesheet' in name:
			continue
		
		var cells_width = texture.get_width() / tile_size
		var cells_height = texture.get_height() / tile_size
		
		tilesheet_dimensions[i] = {
			'width': int(cells_width),
			'height': int(cells_height)
		}
		
		var cell_count = cells_width * cells_height
		
		if i == 0:
			tilesheet_map[i] = cell_count
		else:
			tilesheet_map[i] = tilesheet_map[last_tilesheet_id] + cell_count
			
		if i > 0 and last_tilesheet_id != i - 1:
			tilesheet_gaps[i] = last_tilesheet_id
			
		last_tilesheet_id = i

func get_resource_name(resource_path):
	return resource_path.split('/')[-1]

func get_texture_count():
	if not tile_set:
		return 0
		
	var index = 0
	var exhausted = false
	
	while not exhausted:
		var texture = tile_set.tile_get_texture(index)
		
		if not texture:
			exhausted = true
			
		index += 1
		
	return index
