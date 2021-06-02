extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const EXPLOSION = preload("res://src/Scenes/Attacks/EnemyExplosion.tscn")
const MIN_TIME = 2
var random = RandomNumberGenerator.new()
var next_explosion = MIN_TIME
var timer = 0
onready var root = get_tree().get_root().get_node("World")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer = timer + delta
#	if timer > next_explosion:
#		explosion()
		
func explosion():
	var explosion = EXPLOSION.instance()
	explosion.position = root.get_player_pos()
	add_child(explosion)
	timer = 0
	next_explosion = MIN_TIME + random.randf_range(0, 2)
