extends KinematicBody2D

#should these be consts?
const SPEED = 30000
const DASH_DISTANCE = 600
const DASH_SPEED = 1200
const DASH_COOLDOWN = 1.5
const DASH_COUNT = 2

const DODGE_HEAL = .5
const INVULN_TIME = 0.5


var type = "player"

onready var char_data = $PlayerData
onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var dodge_field = $DodgeField
onready var dodge_hitbox = $DodgeField/DodgeHitbox

#DEPRECATED: motion is probably irrelevant.  
var motion = Vector2()
onready var dash_dir_vector = Vector2()

onready var dash_cd_timer = Timer.new()
onready var invuln_timer = Timer.new()

var dashs_remaining = DASH_COUNT
var dashed_distance = DASH_DISTANCE
var dash_on_cooldown = false
var dodgeable_objects = ["projectile",
					"melee",]


#TODO: Analyze the in-game need for this.   
var forced_movement = false
var external_speed = 0
var external_direction = Vector2(0,0)
var external_time = 0


var current_animation = "Idle"
var current_animation_dir = "S"

signal game_over
signal damage_taken


# Called when the node enters the scene tree for the first time.
func _ready():
	dash_cd_timer.set_one_shot(true)
	dash_cd_timer.set_wait_time(DASH_COOLDOWN)
	dash_cd_timer.connect("timeout", self, "on_dash_cooldown_complete")
	add_child(dash_cd_timer)
	
	invuln_timer.set_one_shot(true)
	invuln_timer.set_wait_time(INVULN_TIME)
	invuln_timer.connect("timeout", self, "on_invuln_end")
	add_child(invuln_timer)

	dodge_field.set_parent(self)
	dodge_field.set_dodgeables(dodgeable_objects)

	#Default Sprite Position
	sprite.playing = true
	sprite.speed_scale = 2
	sprite.animation = current_animation + current_animation_dir

func _physics_process(delta):
	if not char_data.action_state_ == char_data.ACTION_STATE.DISABLED:

		if char_data.action_state_ == char_data.ACTION_STATE.DASHING:
			dashing(delta)
		
		elif char_data.action_state_ == char_data.ACTION_STATE.IDLE or char_data.action_state_ == char_data.ACTION_STATE.MOVING:
			#Char movement
			movement(delta)
			
			#Char dashing
			if (Input.is_action_just_pressed("ui_dash") 
				and not dash_on_cooldown
				and dashs_remaining > 0):
				start_dash()
			
		
		#Allow for god mode
		if Input.is_action_just_pressed("god_mode"):
			char_data.toggle_invuln()

	elif forced_movement:
		external_movement(delta)
		pass

#GETTERS
#region [GETTERS]
func get_type():
	return type

func get_max_HP():
	return char_data.max_HP
	
func get_HP():
	return char_data.get_HP()

func get_movelist():
	return char_data.get_movelist()

func check_type():
	return char_data.get_selected_type()

func instance_scene():
	return char_data.instance_scene()

func special_on_lockout():
	return char_data.special_on_lockout()

func get_move():
	return char_data.get_move()
#endregion

#SETTERS
#region 
func set_camera(path):
	$CameraTransform.set_remote_node(path)

func set_HP(total_cd_amt):
	char_data.set_HP(total_cd_amt)

func set_special(num):
	char_data.current_move = num

	#endregion

#CHANGE STATE FUNCTIONS
#region 
func change_dir_state(direction):
	match direction:
		Vector2(0,1): char_data.direction_state_ = 0  #S
		Vector2(-1,1): char_data.direction_state_ = 1  #SW
		Vector2(-1,0): char_data.direction_state_ = 2  #W
		Vector2(-1,-1): char_data.direction_state_ = 3  #NW
		Vector2(0,-1): char_data.direction_state_ = 4  #N
		Vector2(1,-1): char_data.direction_state_ = 5  #NE
		Vector2(1,0): char_data.direction_state_ = 6  #E
		Vector2(1,1): char_data.direction_state_ = 7  #SE
#endregion

#USER MOVEMENT
#region 
func movement(delta):
	var direction = Vector2()
	var cur_speed = SPEED		
	if Input.is_action_pressed("ui_up"):
		direction += Vector2(0,-1)
	if Input.is_action_pressed("ui_down"):
		direction += Vector2(0, 1)
	if Input.is_action_pressed("ui_right"):
		direction += Vector2(1,0)
	if Input.is_action_pressed("ui_left"):
		direction += Vector2(-1,0)

	change_dir_state(direction)

	if direction != Vector2():
		char_data.action_state_ = char_data.ACTION_STATE.MOVING
		dash_dir_vector = direction
	else:
		char_data.action_state_ = char_data.ACTION_STATE.IDLE

	motion = move_and_slide(direction.normalized() * cur_speed * delta) 
	
#DEPRECATED?
# func set_new_direction(direction):
# 	if dash_dir_vector != direction:
# 		dash_dir_vector = cart(direction)
# 		dash_dir_vector = direction

#endregion

#EXTERNAL MOVEMENT
#region 

func external_movement(delta):
	motion = move_and_collide(external_speed * external_direction * delta)
	external_time -= delta
	if (external_time <= 0):
		char_data.action_state_ = char_data.ACTION_STATE.IDLE
		forced_movement = false
		external_speed = 0
		external_direction = Vector2(0,0)

func force_movement(direction, speed_mult, anim_time):
	char_data.action_state_ = char_data.ACTION_STATE.DISABLED
	forced_movement = true
	external_speed = speed_mult * DASH_SPEED
	external_direction = direction
	external_time = anim_time
		
#endregion

#DASH
#region 

func start_dash():
	dashs_remaining -= 1
	dodge_hitbox.disabled = false
	dir_state_to_dash_direction()
	self.set_collision_mask_bit(3, false)
	char_data.action_state_ = char_data.ACTION_STATE.DASHING

	#DEPRECATED, proof of concept for trail effects
	# print("dash start")
	# dash_effect.visible = true
	# dash_effect.rotation_degrees = rad2deg(dir.angle())
	# dash_effect.play()

func dashing(delta):
	var step = DASH_SPEED * delta if dashed_distance > DASH_SPEED * delta else dashed_distance
	motion = move_and_collide(step*dash_dir_vector)
	dashed_distance -= step
	if dashed_distance <= 0:
		stop_dash()

func stop_dash():
	dashed_distance = DASH_DISTANCE

	if dashs_remaining <= 0:
		dash_on_cooldown = true
	
	dash_cd_timer.start()
	dodge_hitbox.disabled = true
	self.set_collision_mask_bit(3, true)
	char_data.action_state_ = char_data.ACTION_STATE.IDLE

func on_dash_cooldown_complete():
	dash_on_cooldown = false
	dashs_remaining = DASH_COUNT
	dashed_distance = DASH_DISTANCE


func dir_state_to_dash_direction():
	var temp = Vector2()
	match char_data.direction_state_:
		0: temp = Vector2(0,1)  
		1: temp = Vector2(-1,1)
		2: temp = Vector2(-1,0)
		3: temp = Vector2(-1,-1)
		4: temp = Vector2(0,-1)
		5: temp = Vector2(1,-1)
		6: temp = Vector2(1,0)
		7: temp = Vector2(1,1)
	dash_dir_vector = temp.normalized()
	if char_data.action_state_ == char_data.ACTION_STATE.IDLE:
		dash_dir_vector = dash_dir_vector * -1

#endregion


#DODGING
#region 

#TODO: This part has to feel really satisfying
#Timeslow + Chain dodge Nier-esque?

func _on_DodgeField_body_entered(body):
	if (body.has_method("get_type") and 
		dodgeable_objects.has(body.get_type())):
		body.take_damage(self)
		char_data.heal(DODGE_HEAL)

#endregion

#CHARACTER ANIMATIONS
#region 
# func animation_handler():
# 	var anim_name = "Idle"
# 	if char_data.action_state_ == char_data.ACTION_STATE.MOVING:
# 		anim_name = "Walk"
# 	anim_name += dash_dir_vector_cart

# DEPRECATED
# func _on_DashEffect_animation_finished():
# 	dash_effect.visible = false


#TODO: WORK ON THIS POST-ANIMATIONS
func play_new_sprite():
	#if attacking, need to call AnimationPlayer to run appropriate hitbox etc.
	var old_anim = sprite.animation
	var new_anim =  current_animation + current_animation_dir

	#preserve frame of animation upon change of direction only
	#currently only works for Run
	var new_frame = sprite.frame if current_animation in old_anim else 0


	print(new_anim, new_frame)
	if char_data.action_state_ == char_data.ACTION_STATE.ATTACKING:
		
		anim_player.play(new_anim)
		#HACK need to decide what to do regarding this
		
	else:
		sprite.animation = new_anim
		sprite.frame = new_frame

func _on_AnimationPlayer_animation_finished(_anim):
	print("finished")
	char_data.action_state_ = char_data.ACTION_STATE.IDLE
	pass

#endregion

#DAMAGE MECHANICS
#region 
func take_damage(obj):
	char_data.take_damage(obj.attack_data.damage)
		#TODO: Invuln timer way too slow proportional to cooldown times. 
	if "knockback_val" in obj.attack_data:
		motion = move_and_collide(obj.direction * obj.attack_data.knockback_val)

func invulnerable(time):
	invuln_timer.start(time)
	current_animation = "Damaged"
	char_data.action_state_ = char_data.ACTION_STATE.DISABLED
	char_data.damage_state_ = char_data.DAMAGE_STATE.INVULN
	
func on_invuln_end():
	char_data.damage_state_ = char_data.DAMAGE_STATE.IDLE
	char_data.action_state_ = char_data.ACTION_STATE.IDLE
	play_new_sprite()
#endregion

#SIGNALS FROM GAMESTATE CHANGES
#region 
func _on_PlayerData_action_state_change(_state):
	#if attacking, get the type of attack animation
	#if moving
	match _state:
		0: current_animation = "Idle" #Idle
		1: current_animation = "Run" #Moving
		2: current_animation = "Kick" #Attacking
			#if attacking, get the type of attack animation from attacker
			#HACK: currently does not handle anything other than LClick
		3: current_animation = "Dash" #Dashing
		#4: Blocking 
			#TODO: determine if want blocking
		5: pass 
			#TODO: determine how to handle disabled animation
		_: current_animation = "Idle"
	play_new_sprite()

func _on_PlayerData_damage_state_change(_state):
	#HACK obviously need to handle things better
	emit_signal("damage_taken")
	match _state:
		0: current_animation = "Idle" 	#	IDLE,
		1: invulnerable(INVULN_TIME) 	#	HIT,
		2: invulnerable(INVULN_TIME) 	#	COUNTERHIT,
		3: print("invuln")				#	INVULN,
	play_new_sprite()

func _on_PlayerData_direction_state_change(_state):	
	match _state:
		0: current_animation_dir = "S"
		1: current_animation_dir = "SW"
		2: current_animation_dir = "W"
		3: current_animation_dir = "NW"
		4: current_animation_dir = "N"
		5: current_animation_dir = "NE"
		6: current_animation_dir = "E"
		7: current_animation_dir = "SE"
	play_new_sprite()
#endregion

#SIGNALS TO GAMEMANAGER
#region 

#HEALTH INFORMATION SIGNALS
func _on_HPData_dead():
	emit_signal("game_over")
	pass # Replace with function body.

#endregion


#TURN ON/OFF ANY CHAR INTERACTIONS
#region 

func disable():
	char_data.action_state_ = char_data.ACTION_STATE.DISABLED
	$Drawer.disable()

func enable():
	char_data.action_state_ = char_data.ACTION_STATE.IDLE
	$Drawer.enable()

#endregion


