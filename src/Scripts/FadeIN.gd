extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal fade_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fade_in():
	$AnimationPlayer.play("FadeIn")



func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("fade_finished") # Replace with function body.
