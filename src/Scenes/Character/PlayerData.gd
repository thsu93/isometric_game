extends "CharacterData.gd"

var special_node = preload("res://src/Scenes/Attacks/AbilityInfo.gd")

var selected_move_nums = [1,2,3,4,5,]
var specials = []
var current_move = 0

func _ready():
	max_HP = 5
	HP = max_HP
	for move in selected_move_nums:
		var child = Node.new()
		child.name = "Move" + String(move)
		child.script = special_node
		add_child(child)
		child.set_current_ability(move)
		specials.append(child)

func _process(_delta):
	var total_cd = 0
	for node in specials:
		total_cd += node.current_cd_time
	HP = max_HP - total_cd

func set_HP(total_cd_amt):
	HP = max_HP - total_cd_amt

func get_HP():
	return HP

func get_movelist():
	return specials

func get_selected_type():
	return specials[current_move].get_type()

func instance_scene():
	specials[current_move].activate()
	return specials[current_move].get_instance()

func get_move():
	return specials[current_move]
					
#Currently copy of TakeDamage for CharData
#Here for possible overloading.
func take_damage(dmg):
	if not damage_state_ == DAMAGE_STATE.INVULN:
		match (action_state_):
			ACTION_STATE.DASHING:
				pass
			ACTION_STATE.ATTACKING:
				HP -= dmg	#Should some sort of multiplier?
				specials[current_move].take_damage(dmg)
				damage_state_ = DAMAGE_STATE.COUNTERHIT
				emit_signal("damage_state_change", damage_state_)
				#multiplied damage
			#STATE.BLOCKING:
				#reduced damage
			_:
				HP -= dmg
				specials[current_move].take_damage(dmg)
				damage_state_ = DAMAGE_STATE.HIT
				emit_signal("damage_state_change", damage_state_)
		if HP <= 0:
			emit_signal("dead")


func heal(amt):
	specials[current_move].current_cd_time -= amt

func special_on_lockout():
	return specials[current_move].on_cooldown
