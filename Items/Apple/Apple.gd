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
		$Shadow.visible = false
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		PlayerStats.maxHealth += 1
		PlayerStats.hearts +=1
		PlayerStats.set_max_hearts(PlayerStats.maxHealth)
		PlayerStats.set_hearts(PlayerStats.hearts)
		$AnimationPlayer.play("Animate")
		Global.playerCoins = Global.playerCoins - 10
