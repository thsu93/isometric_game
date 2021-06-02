# TODO: Review this function. 

extends Node2D

var character
var type = "player"
var dodgeable_objects = []

func set_dodgeables(objs):
	dodgeable_objects = objs

func get_type():
	return type
	
func set_parent(parent):
	character = parent
	
# func take_damage(obj):
# #		char_data.take_damage(obj.attack_data.damage)
# #		invulnerable()
# #		invuln_timer.start()
# #		$AnimationPlayer.play("Invuln")
# 		#TODO: Invuln timer way too slow proportional to cooldown times. 
# 	pass
