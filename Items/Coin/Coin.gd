extends RigidBody2D

onready var animatedSprite = $AnimatedSprite
var canPlay = false

func _ready():
	$CoinDropped.play(0.0)

func _physics_process(delta):
	if !canPlay:
		animatedSprite.play("Drop")
		yield(animatedSprite, "animation_finished")
		canPlay = true
	if canPlay:
		animatedSprite.play("Animate")


func _on_Area2D_body_entered(body):
	if body.get_name() == "Player" or body.get_name() == "MoonTransformation":
		#if body.add_coins(amount):
		Global.playerCoins += 1
		$CoinDropped.stop()
		$AnimatedSprite.visible = false
		$Shadow.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		$Area2D/CollisionShape2D.set_deferred("disabled",true)
		$CoinPickUp.play(0.0)
		yield($CoinPickUp, "finished")
		queue_free()
