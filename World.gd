extends Node2D

var enemies = [
	preload("res://Enemies/Skeleton/Skeleton.tscn"),
	preload("res://Enemies/Snake/Snake.tscn"),
	preload("res://Enemies/CrazyDemon/CrazyDemon.tscn")
]
const EnemyGolem = preload("res://Enemies/ShadowGolem/ShadowGolem.tscn")

const MoonTransformation = preload("res://Player/MoonTransformation/MoonTransformation.tscn")
const Player = preload("res://Player/Player.tscn")
const Trader = preload("res://Trader/SamuraiMerchant.tscn")

onready var spawner1 = $SpawnersAndBlockers/SpawnAndBlock1
onready var spawner2 = $SpawnersAndBlockers/SpawnAndBlock2
onready var spawner3 = $SpawnersAndBlockers/SpawnAndBlock3
onready var spawner4 = $SpawnersAndBlockers/SpawnAndBlock4

onready var camera = $Camera2D
onready var locations = [spawner1.global_position, spawner2.global_position, spawner3.global_position, spawner4.global_position]

var randomizer = RandomNumberGenerator.new()
var randomNumber = 0

var timerStopWatch2 = null
var timerStopWatch = null
var timerGolem = null
var timerSpawnRate = null
var timerTransformation = null
var timerItemCD = null
var timerTransformationDuration = null

var notTransfromed = true
var transformationOnCD = false
var hourGlassOnCD = false
var LOrbCD = false

var traderSpawned = false



func _ready():
	Global.connect("itemPickedUp", self, "active_Item_Display")
	$TraderStart/CollisionShape2D.set_deferred("disabled", true)

	randomize()
	randomizer.randomize()
	
	timerSpawnRate = Timer.new()
	timerSpawnRate.set_one_shot(true)
	timerSpawnRate.set_wait_time(Global.spawnerRate)
	timerSpawnRate.connect("timeout", self, "on_timeout_complete_SpawnRate")
	add_child(timerSpawnRate)
	
	timerGolem = Timer.new()
	timerGolem.set_one_shot(true)
	timerGolem.set_wait_time(15)
	timerGolem.connect("timeout", self, "on_timeout_complete_Golem")
	add_child(timerGolem)
	
	timerStopWatch = Timer.new()
	timerStopWatch.set_one_shot(true)
	timerStopWatch.set_wait_time(0.08)
	timerStopWatch.connect("timeout", self, "on_timeout_complete_StopWatch")
	add_child(timerStopWatch)
	
	timerStopWatch2 = Timer.new()
	timerStopWatch2.set_one_shot(true)
	timerStopWatch2.set_wait_time(0.079)
	timerStopWatch2.connect("timeout", self, "on_timeout_complete_StopWatch2")
	add_child(timerStopWatch2)
	
	timerTransformation = Timer.new()
	timerTransformation.set_one_shot(true)
	timerTransformation.set_wait_time(2)
	timerTransformation.connect("timeout", self, "on_timeout_complete_transformation")
	add_child(timerTransformation)
	
	timerTransformationDuration = Timer.new()
	timerTransformationDuration.set_one_shot(true)
	timerTransformationDuration.set_wait_time(18)
	timerTransformationDuration.connect("timeout", self, "on_timeout_complete_transformation_duration")
	add_child(timerTransformationDuration)
	
	timerItemCD = Timer.new()
	timerItemCD.set_one_shot(true)
	timerItemCD.set_wait_time(30)
	timerItemCD.connect("timeout", self, "on_timeout_complete_item_CD")
	add_child(timerItemCD)



func _input(event):
	if Input.is_key_pressed(KEY_Q):
		if Global.LOrbCanCast and !LOrbCD:
			$YSort/Player.castOrb()
			hourGlassOnCD = true
			transformationOnCD = true
			LOrbCD = true
			timerItemCD.set_wait_time(9)
			$CameraHolder/HearthUI.startCDTimer(9)
			timerItemCD.start()
		if !Global.enginePause and Global.canStopTime and !hourGlassOnCD:
				Engine.time_scale = 0.01
				$YSort/Player.stopTime()
				Global.enginePause = true
				camera.smoothing_speed = 500
				timerStopWatch.start()
				timerStopWatch2.start()
				hourGlassOnCD = true
				transformationOnCD = true
				LOrbCD = true
				timerItemCD.set_wait_time(30)
				$CameraHolder/HearthUI.startCDTimer(30)
				timerItemCD.start()
		if notTransfromed and Global.canChange and !transformationOnCD:
			notTransfromed = false
			Global.canChange = false
			var moonTransformation = MoonTransformation.instance()
			var remoteTransform2D = RemoteTransform2D.new()
			Global.emit_signal("transformationOver")
			yield($YSort/Player, "tree_exiting")
			get_node("YSort").add_child(moonTransformation)
			moonTransformation.global_position = $YSort/Player.global_position
			moonTransformation.add_child(remoteTransform2D)
			remoteTransform2D.remote_path = "/root/World/Camera2D"
			timerTransformation.start()
			transformationOnCD = true
			hourGlassOnCD = true
			LOrbCD = true
			timerItemCD.set_wait_time(45)
			$CameraHolder/HearthUI.startCDTimer(45)
			timerItemCD.start()
			timerTransformationDuration.start()
		elif !notTransfromed and Global.canChange:
			notTransfromed = true
			Global.canChange = false
			var player = Player.instance()
			var remoteTransform2D = RemoteTransform2D.new()
			Global.emit_signal("transformationOver")
			yield($YSort/MoonTransformation, "tree_exiting")
			get_node("YSort").add_child(player)
			player.global_position = $YSort/MoonTransformation.global_position
			player.add_child(remoteTransform2D)
			remoteTransform2D.remote_path = "/root/World/Camera2D"
			timerTransformation.start()
			
	if Input.is_action_pressed("ui_cancel"):
		if Global.enginePause == true:
			$YSort/Player.resumeTime()
			Engine.time_scale = 1
			Global.enginePause = false
			camera.smoothing_speed = 5
			Global.velocityAdjusting = false
		get_tree().change_scene("res://GUI/Menu/Menu.tscn")
	if Input.is_action_pressed("ui_page_up"):
				camera.zoom.x -= 0.1
				camera.zoom.y -= 0.1
	if Input.is_action_pressed("ui_page_down"):
			if !camera.zoom.x >= 1.5 and !camera.zoom.y >1: 
				camera.zoom.x += 0.1
				camera.zoom.y += 0.1
	if Input.is_key_pressed(KEY_T) and Global.traderPause:
		$TraderStart/CollisionShape2D.set_deferred("disabled", false)



func _physics_process(delta):
	if Global.traderPause and !traderSpawned:
		var trader = Trader.instance()
		get_node("YSort").add_child(trader)
		trader.global_position = $TraderStart/CollisionShape2D.global_position
		traderSpawned = true
	if Global.canSpawn and !Global.traderPause:
		traderSpawned = false
		var enemyGolem
		randomNumber = randi() % 3
		var enemyInstance = enemies[randomNumber].instance()
		get_node("YSort").add_child(enemyInstance)
		randomNumber = randi() % 4
		var location = locations[randomNumber]
		if randomNumber == 0 or randomNumber == 1:
			location.x = randomizer.randi_range(-200, 500)
		elif randomNumber == 2 or randomNumber == 3:
			location.y = randomizer.randi_range(-200, 400)
		enemyInstance.position = location
		if Global.spawnGolem == true:
			enemyGolem = EnemyGolem.instance()
			get_node("YSort").add_child(enemyGolem)
			enemyGolem.position = location
			Global.spawnGolem = false
			timerGolem.start()
		Global.canSpawn = false
		timerSpawnRate.start()

func _on_Trader_body_entered(body):
	$Trader/CollisionShape2D.set_deferred("disabled",true)

func _on_TraderStart_body_entered(body):
	Global.traderPause = false
	$TraderStart/CollisionShape2D.set_deferred("disabled",true)
	$Trader/CollisionShape2D.set_deferred("disabled",false)

func active_Item_Display():
	if Global.canChange:
		$CameraHolder/HearthUI.itemTexture(1)
	elif Global.LOrbCanCast:
		$CameraHolder/HearthUI.itemTexture(3)
	elif Global.canStopTime:
		$CameraHolder/HearthUI.itemTexture(2)


func on_timeout_complete_transformation_duration():
	if !notTransfromed:
		notTransfromed = true
		Global.canChange = false
		var player = Player.instance()
		var remoteTransform2D = RemoteTransform2D.new()
		Global.emit_signal("transformationOver")
		yield($YSort/MoonTransformation, "tree_exiting")
		get_node("YSort").add_child(player)
		player.global_position = $YSort/MoonTransformation.global_position
		player.add_child(remoteTransform2D)
		remoteTransform2D.remote_path = "/root/World/Camera2D"
		timerTransformation.start()

func on_timeout_complete_StopWatch():
	$YSort/Player.resumeTime()
	Engine.time_scale = 1
	Global.enginePause = false
	camera.smoothing_speed = 5
	Global.velocityAdjusting = false

func on_timeout_complete_StopWatch2():
	Global.velocityAdjusting = true

func on_timeout_complete_SpawnRate():
	Global.canSpawn = true

func on_timeout_complete_Golem():
	Global.spawnGolem = true

func on_timeout_complete_transformation():
	Global.canChange = true

func on_timeout_complete_item_CD():
	transformationOnCD = false
	hourGlassOnCD = false
	LOrbCD = false
