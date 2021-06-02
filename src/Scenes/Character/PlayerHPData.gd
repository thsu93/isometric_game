extends "CharacterData.gd"

#TODO: Necessary?
signal damage_taken(HP)

var special_node = preload("AbilityInfo.gd")

var selected_move_nums = [1,2,3,4,5,]
var player_specials

func _ready():
	max_HP = 5
	HP = max_HP
	for move in selected_move_nums:
		
		pass

func take_damage(dmg):
	if HP <= 0:
		emit_signal("dead")
	else:
		HP -= dmg
		emit_signal("damage_taken", dmg)

func set_HP(total_cd_amt):
	HP = max_HP - total_cd_amt

func get_HP():
	return HP
