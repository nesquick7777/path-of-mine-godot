extends StaticBody2D

onready var animateTransform = $AnimationPlayer
var truth = false
var canTransfrom = true

func _on_Area2D_body_entered(body):
	if canTransfrom:
		if truth:
			animateTransform.play("Transform")
		truth = true

func _on_Area2D_area_entered(area):
	if canTransfrom:
		if truth:
			animateTransform.play("Transform")
		truth = true

func _IdleA():
	canTransfrom = false
	animateTransform.play("IdleA")
