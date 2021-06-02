extends "AttackData.gd"

#Temporary Workaround
export(NodePath)var animated_sprite

func _ready():
	knockback_val = 10
	lifespan = 5
	damage = 10
	speed = 1000
	collidables = [	"enemy",
					"projectile",]
	get_node(animated_sprite).play("Fireball_R")
