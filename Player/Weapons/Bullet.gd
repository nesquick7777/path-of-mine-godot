extends Area2D

var vel = Vector2()
export var speed = 300
var direction = 1
var knockback_vector = Vector2.ZERO
export var damage = 1
var canTravel = true

func _physics_process(delta):
	if canTravel:
		translate(vel* speed *delta)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _set_fireball_directionH(dirH):
	direction = dirH
	vel = dirH.normalized()
	look_at(direction.normalized())

func _set_fireball_directionV(dirV):
	direction = dirV
	vel = dirV.normalized()
	look_at(direction.normalized())


func _on_Bullet_body_entered(body):
	if body.name == "Obelisk":
		pass
	else:
		canTravel = false
		$CollisionShape2D.set_deferred("disabled", true)
		$Particles2D.visible = false
		$AnimationPlayer.play("impact")
		$AudioStreamPlayer2D.play()
		yield($AudioStreamPlayer2D, "finished")
		queue_free()


func _on_Bullet_area_entered(area):
	if area.name == "ZIndex":
		z_index = 0
	else:
		canTravel = false
		$CollisionShape2D.set_deferred("disabled", true)
		$Particles2D.visible = false
		$AnimationPlayer.play("impact")
		$AudioStreamPlayer2D.play()
		yield($AudioStreamPlayer2D, "finished")
		queue_free()

func _on_FenceRealHit_area_entered(_area):
	if Global.zIndex == true:
		z_index = 0
	else:
		z_index = 1

