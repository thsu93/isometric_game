extends Node2D


onready var hitbox = $MeleeHitbox/Hitbox
onready var attack_data = get_node("AttackData")

var type = "melee"

func get_type():
	return type

func _on_MeleeHitbox_body_shape_entered(_body_id, body, _body_shape, _area_shape):
	if (body.has_method("get_type") and 
		body.get_type() in attack_data.collidables):
		print("Hit")
		body.take_damage(self)
