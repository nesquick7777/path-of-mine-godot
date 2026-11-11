extends Node2D

func _physics_process(_delta):
	if ParticlesCache.loaded:
		set_physics_process(false)

func _on_Button2_pressed():
	get_tree().quit()

func _on_Button3_pressed():
	PlayerStats.maxHealth = PlayerStats.reset
	PlayerStats.hearts = PlayerStats.reset
	PlayerStats.acceleration =PlayerStats.resetAcceleration
	PlayerStats.friction = PlayerStats.resetFriction
	PlayerStats.max_speed = PlayerStats.resetMax_speed
	PlayerStats.dash_speed = PlayerStats.resetDash_speed
	ObeliskStats.hearts2 = 10
	ObeliskStats.maxHearts2 = 10
	Global.spawnerRate = 9
	Global.playerCoins = 0
	Global.canChange = false
	Global.LOrbCanCast = false
	Global.canStopTime = false
	get_tree().change_scene("res://World.tscn")
