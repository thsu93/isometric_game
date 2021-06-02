extends KinematicBody2D

const LOCKOUT = 1.5
const BULLET = preload("res://src/Scenes/Attacks/EnemyBullet.tscn")
onready var root = get_tree().get_root().get_node("World")

var timer = 0
var type = "enemy"
var knockback_loc = Vector2()

func _physics_process(delta):
	timer = timer + delta
	if timer>LOCKOUT:
		shoot()
		timer = 0
	var step = knockback_loc * delta if knockback_loc * delta > knockback_loc else knockback_loc
	move_and_collide(step)
	knockback_loc -= step

func get_type():
	return type

func shoot():
	var target_loc = root.get_player_pos()
	var cur_pos = self.get_position()
	var spawn = BULLET.instance()
	$Shooter.shoot(spawn, target_loc, cur_pos)
	
	root.spawn(spawn)

func take_damage(obj):
	$HPData.take_damage(obj.attack_data.damage)
	if "direction" in obj:
		knockback_loc = obj.direction * obj.attack_data.knockback_val
#	var step = knockback * delta if dashed_distance > SPEED * delta else dashed_distance

func _on_Node_dead():
	queue_free()
	pass # Replace with function body.

func _on_Node_health_changed(life):
	#currently nothing
	pass # Replace with function body.
