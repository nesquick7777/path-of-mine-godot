extends StaticBody2D

var truth = false
onready var animationBush = $AnimationBush
func _stop():
	animationBush.play("Idle")


func _on_Area2D_body_entered(body):
	if truth:
		animationBush.play("Touched")
	truth = true

func _on_Area2D_area_shape_entered(area_id, area, area_shape, local_shape):
	if truth:
		animationBush.play("Touched")
	truth = true
