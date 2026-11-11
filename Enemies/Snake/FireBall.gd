extends KinematicBody2D

export var speed = 210
var direction = Vector2.ZERO
export var damage = 1
var canTravel = true
onready var hitBox = $Hitbox

func _ready():
	$Sprite.play("Animate")

enum{
MOVE,
IMPACT
}
var state = MOVE

func _physics_process(delta):
	match state:
		IMPACT:
			z_index = 1
			$Sprite.play("Impact")
			$CollisionShape2D.set_deferred("disabled", true)
			$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			$Area2D/CollisionShape2D.set_deferred("disabled", true)
			yield($Sprite, "animation_finished")
			$Sprite.visible = false
			yield($AudioStreamPlayer2D,"finished")
			queue_free()
		MOVE:
			if direction != null:
				hitBox.knockback_vector2 = direction.normalized()
				direction = direction.normalized()
				direction *= scale
				var velocity = direction
				if canTravel:
					move_and_collide(velocity * speed * delta)
			else:
				pass


func _set_fireball_directionH(dirH):
	direction = dirH
	$Sprite.look_at(direction)
	$Hitbox.look_at(direction)
	$CollisionShape2D.look_at(direction)

func _on_Hitbox_area_entered(area):
	if area.name == "Hurtbox":
		$AudioStreamPlayer2D.play(0.0)
		state = IMPACT
	else:
		pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Area2D_body_entered(body):
	z_index = 1


func _on_Area2D_area_entered(area):
	z_index = 1

func _on_ObjectChecker_body_entered(body):
	$AudioStreamPlayer2D.play(0.0)
	state = IMPACT
