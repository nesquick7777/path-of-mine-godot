extends StaticBody2D

var timer = null

func _ready():
	$Coin.visible = false
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.5)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	timer.start()

func on_timeout_complete():
	$Coin.visible = true

func _physics_process(delta):
	if Input.is_key_pressed(KEY_T):
		$Coin.visible = false
		$Sprite.visible = false
		$Shadow.visible = false
		$AnimationPlayer.play("Animate")

func _on_Area2D_body_entered(body):
	if Global.playerCoins >= 0:
		$Coin.visible = false
		$Sprite.visible = false
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		$Shadow.visible = false
		PlayerStats.max_speed += 30
		PlayerStats.dash_speed += 20
		PlayerStats.acceleration += 167
		PlayerStats.friction += 134
		PlayerStats.set_dash_speed(PlayerStats.dash_speed)
		PlayerStats.set_max_speed(PlayerStats.max_speed)
		PlayerStats.set_acceleration(PlayerStats.acceleration)
		PlayerStats.set_friction(PlayerStats.friction)
		Global.playerCoins = Global.playerCoins - 10
		$AnimationPlayer.play("Animate")
