extends Node2D

onready var attack_data = get_node("AttackData")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = "area"
var lifespan
var lifetime = 0

func _ready():
	lifespan = attack_data.lifespan

func get_type():
	return type
	
func _physics_process(delta):
	lifetime = lifetime + delta
	if lifetime > lifespan:
		queue_free()

func _on_Hitbox_body_shape_entered(body_id, body, body_shape, area_shape):
	if (body.has_method("get_type") and 
		body.get_type() in attack_data.collidables):
		body.take_damage(self)
	self.take_damage(body)
	
func take_damage(_obj):
	queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free() # Replace with function body.
