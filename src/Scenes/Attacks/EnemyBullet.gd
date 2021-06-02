extends "AttackData.gd"

func _ready():
	knockback_val = 10
	lifespan = 5
	damage = 3
	speed = 800
	collidables = [	"player",
					"melee",
					"area",
					"projectile",]
