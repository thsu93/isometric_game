extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var attack_data = get_node("AttackData")
onready var sprite = get_node("Sprite")
onready var hitbox = get_node("CollisionShape2D")
onready var animator = get_node("AnimationPlayer")

var direction=Vector2()
var collidables 
var lifespan
var lifetime = 0
var speed = 0

var animating = false
var collided = false
var type = "projectile"

func _ready():
	lifespan = attack_data.lifespan
	speed = attack_data.speed if attack_data.speed else 0

func set_dir(dir):
	direction = dir
	self.rotation_degrees = rad2deg(direction.angle())
	
func get_type():
	return type
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	lifetime = lifetime + delta
	var collision_info = move_and_collide(direction*speed*delta)
	
	if collision_info:
		collided = true
		speed = 0
		var body = collision_info.collider
		
		if (body.has_method("get_type") and 
			attack_data.collidables.has(body.get_type())):
			body.take_damage(self)
		
		self.take_damage(body)
		
	if (collided or lifetime > 5) and not animating:
		queue_free()

func take_damage(obj):
	# hitbox.disabled = true
	sprite.visible = false
	animator.play("Explosion")
	self.speed = 0
	if "direction" in obj:
		self.position += obj.direction*obj.attack_data.knockback_val

#ANIMATION HANDLING
func _on_AnimationPlayer_animation_started(_anim_name):
	animating = true

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
