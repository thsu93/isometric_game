extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const DAMAGE_TIMER = 1
const DESPAWN = 2
var timer = 0
var obj_inside

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Explosion")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer = timer + delta
	if timer > DAMAGE_TIMER and obj_inside != null:
		#need to fix this
		pass
	if timer > DESPAWN:
		queue_free()

func _on_Explosion_body_shape_entered(body_id, body, body_shape, area_shape):
	obj_inside = body

func _on_Explosion_body_shape_exited(body_id, body, body_shape, area_shape):
	obj_inside = null
