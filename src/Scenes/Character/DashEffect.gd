extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal animation_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func play():
	$Dash.play()

func set_offset(direction):
	$Dash.set_offset(direction*5)

func _on_Dash_animation_finished():
	$Dash.stop()
	emit_signal("animation_finished")
