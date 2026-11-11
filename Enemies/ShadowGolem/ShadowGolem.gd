extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var hitBox = $Position2D/Hitbox

var speed = 115
var target = null
var canMove = true
var timer = null
var timer2 = null
var string = "Run2"

enum{
	LIFE,
	DEATH
}
var state = LIFE

func _ready():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(10)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	timer2 = Timer.new()
	timer2.set_one_shot(true)
	timer2.set_wait_time(1.5)
	timer2.connect("timeout", self, "on_timeout_complete2")
	add_child(timer2)
	timer.start()
	$Idle.play(0.0)

func on_timeout_complete():
	canMove = false
	$Position2D/Hitbox/CollisionShape2D.set_deferred("disabled", false)
	$Hurtbox.set_deferred("monitoring", false)
	string = "Run"
	speed = 90
	timer2.start()


func on_timeout_complete2():
	canMove = true
	string = "Run"
	speed = 90
	$Idle.play(0.0)
	$Hurtbox.set_deferred("monitoring", false)
	$Position2D/Hitbox/CollisionShape2D.set_deferred("disabled", true)
	timer.start()

func _physics_process(delta):
	match state:
		DEATH:
			target = null
			animationPlayer.play("Death")
		LIFE:
				if target:
					var velocity = global_position.direction_to(target.global_position)
					if !Global.enginePause:
						sprite.flip_h = velocity.x < 0
					if velocity.x < 0:
						hitBox.position.x = -20
					else:
						hitBox.position.x = 0
					if velocity.x<0:
						if velocity.y==0:
							hitBox.knockback_vector2 = Vector2(-1,0)
						elif velocity.y<0:
							hitBox.knockback_vector2 = Vector2(-1,-1)
						else:
							hitBox.knockback_vector2 = Vector2(-1,1)
					elif velocity.x>0:
						if velocity.y==0:
							hitBox.knockback_vector2 = Vector2(1,0)
						elif velocity.y<0:
							hitBox.knockback_vector2 = Vector2(1,-1)
						else:
							hitBox.knockback_vector2 = Vector2(1,1)
					elif velocity.y<0:
						hitBox.knockback_vector2 = Vector2(0,-1)
					else:
						hitBox.knockback_vector2 = Vector2(0,1)
					if canMove:
						if string != "Attack2":
							animationPlayer.play(string)
							$Hurtbox.set_deferred("monitoring", true)
							move_and_collide(velocity * speed * delta)
						else:
							animationPlayer.play(string)
							move_and_slide(velocity * speed * delta * 140)
							yield(animationPlayer, "animation_finished")
							canMove = false
							timer.stop()
							timer2.start()
					else:
						animationPlayer.play("Idle")


func on_death():
	$Position2D/Hitbox/CollisionShape2D.set_deferred("disabled", true)
	state = DEATH


func _on_LookForPlayer_body_entered(body):
	if body.name == "Player" or body.name == "MoonTransformation":
		target = body

func _on_LookForPlayer_body_exited(body):
	if body.name == "Player" or body.name == "MoonTransformation":
		target = null

func _on_Hurtbox_body_entered(body):
	if body.name == "FireCamp":
		on_death()
	elif body.name == "Player" or body.name == "MoonTransformation" and canMove and string == "Run":
		string = "Attack"
	elif body.name == "Player" or body.name == "MoonTransformation" and canMove and string == "Run2":
		string = "Attack2"
		$Grunt.play(0.0)
