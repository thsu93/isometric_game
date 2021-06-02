tool
extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var offset = Vector2(-192.0, -288.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	for tile in tile_set.get_tiles_ids().size():
		tile_set.tile_set_texture_offset(tile, offset)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
