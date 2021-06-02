extends Node

signal dead
signal action_state_change(state_)
signal damage_state_change(state_)
signal direction_state_change(state_)


enum ACTION_STATE{
	IDLE,
	MOVING,
	ATTACKING,
	DASHING,
	BLOCKING,
	DISABLED,
	};

enum DAMAGE_STATE{
	IDLE,
	HIT,
	COUNTERHIT,
	INVULN,
}

enum DIRECTION_STATE{
	S,
	SW,
	W,
	NW,
	N,
	NE,
	E,
	SE,
}

var action_state_ = ACTION_STATE.IDLE
var prev_action_state_ = action_state_

var damage_state_ = DAMAGE_STATE.IDLE
var prev_damage_state_ = damage_state_

var direction_state_ = DIRECTION_STATE.S
var prev_direction_state_ = direction_state_

var HP = 5
export(int) var max_HP = 5

func _ready():
	HP = max_HP

func _process(_delta):
	if not action_state_ == prev_action_state_:
		emit_signal("action_state_change", action_state_)
		prev_action_state_ = action_state_

	if not direction_state_ == prev_direction_state_:
		emit_signal("direction_state_change", direction_state_)
		prev_direction_state_ = direction_state_

	if not damage_state_ == prev_damage_state_:
		emit_signal("damage_state_change", damage_state_)
		prev_damage_state_ = damage_state_


func take_damage(dmg):
	if not damage_state_ == DAMAGE_STATE.INVULN:
		match (action_state_):
			ACTION_STATE.DASHING:
				pass
			ACTION_STATE.ATTACKING:
				HP -= dmg	#Should some sort of multiplier?
				damage_state_ = DAMAGE_STATE.COUNTERHIT
				emit_signal("damage_state_change", damage_state_)
				#multiplied damage
			#STATE.BLOCKING:
				#reduced damage
			_:
				HP -= dmg
				damage_state_ = DAMAGE_STATE.HIT
				emit_signal("damage_state_change", damage_state_)
		if HP <= 0:
			emit_signal("dead")
			

#TODO: What does this do?
func toggle_invuln():
	if damage_state_ == DAMAGE_STATE.INVULN:
		damage_state_ = DAMAGE_STATE.IDLE
	else: 
		damage_state_ = DAMAGE_STATE.INVULN

