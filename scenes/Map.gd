extends Node2D

var tile_maps

onready var tile_layer0 = get_node('TileLayer0')
onready var tile_layer1 = get_node('TileLayer1')
onready var tile_layer2 = get_node('TileLayer2')
onready var tile_layer3 = get_node('TileLayer3')
onready var tile_layer4 = get_node('TileLayer4')

func _ready():
	tile_maps = [tile_layer0, tile_layer1, tile_layer2, tile_layer3, tile_layer4]
