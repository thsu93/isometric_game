extends "res://src/Scenes/Attacks/AttackData.gd"

func _ready():
	damage = 10
	collidables = [	"enemy",
					"projectile",]