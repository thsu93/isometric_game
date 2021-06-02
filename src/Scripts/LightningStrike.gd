extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = $AnimationPlayer
onready var hitbox = $Hitbox
var lifetime = .5
var timer = 0
signal hit(collider)

var type = "area"

# Called when the node enters the scene tree for the first time.
func _ready():
	player.play("Strike") # Replace with function body.

func get_type():
	return type

func _on_Hitbox_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.has_method("get_type") and (body.get_type()=="enemy" or body.get_type() == "projectile"):
		body.take_damage(Vector2(), 0)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free() # Replace with function body.
