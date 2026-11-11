extends KinematicBody2D

const ItemSpawnNormal = preload("res://Items/ItemSpawnBlue.tscn")
const ItemSpawnEpic = preload("res://Items/ItemSpawnRed.tscn")

onready var itemsArray = [
	preload("res://Items/BasicBoots/BasicBoots.tscn"),
	preload("res://Items/Apple/Apple.tscn")
]

onready var itemsArrayRare =[
	preload("res://Items/BookOfTransformation/BookOfTransformation.tscn"),
	preload("res://Items/LightningOrb/LightningOrb.tscn"),
	preload("res://Items/HourGlass/HourGlass.tscn")
]

onready var animationPlayer = $AnimationPlayer
var target = null
var speed = 50
var canMove = true
var timerSpawnDelay = null
var timerReminder = null
var randomNumber = 0
var canSpawn = true
var thirdItem = false

func _ready():
	randomize()
	
	timerReminder = Timer.new()
	timerReminder.set_one_shot(true)
	timerReminder.set_wait_time(5)
	timerReminder.connect("timeout",self,"on_timeout_complete_reminder" )
	add_child(timerReminder)
	
	timerSpawnDelay = Timer.new()
	timerSpawnDelay.set_one_shot(true)
	timerSpawnDelay.set_wait_time(0.5)
	timerSpawnDelay.connect("timeout",self,"on_timeout_complete_timerSpawnDelay" )
	add_child(timerSpawnDelay)
	$Reminder.visible = false

func _physics_process(delta):
	if !canMove and canSpawn and Global.traderPause:
		spawn()
		canSpawn = false
	elif !canSpawn and canMove and Global.traderPause:
		canSpawn = true
	if target:
		var velocity = global_position.direction_to(target.global_position)
		$Sprite.flip_h = velocity.x < 0
		if velocity.x < 0:
			$Position2D.position.x = -19
		else:
			$Position2D.position.x = 19
		if canMove:
			animationPlayer.play("Run")
			move_and_collide(velocity * speed * delta)
		else:
			animationPlayer.play("Idle")



func _on_LookForSpot_area_entered(area):
	if area.name == "Trader" or area.name == "TraderStart":
		$Reminder.visible = false
		target = area
		canMove = true

func _on_LookForSpot_area_exited(area):
	if area.name == "Trader":
		canMove = false
	elif area.name == "TraderStart":
		queue_free()

func spawn():
	timerReminder.start()
	randomNumber = randi() % itemsArray.size()
	var item1 = itemsArray[randomNumber].instance()
	var itemSpawnNormal = ItemSpawnNormal.instance()
	var spawnerEffectPosition1 = $ItemLocation1.global_position
	spawnerEffectPosition1.y = -10
	get_parent().call_deferred("add_child", item1)
	get_parent().call_deferred("add_child", itemSpawnNormal)
	item1.global_position = $ItemLocation1.global_position
	itemSpawnNormal.global_position = spawnerEffectPosition1
	itemSpawnNormal.z_index = 1
	timerSpawnDelay.start()

func on_timeout_complete_timerSpawnDelay():
	if !thirdItem:
		randomNumber = randi() % itemsArrayRare.size()
		var item2 = itemsArrayRare[randomNumber].instance()
		var itemSpawnEpic = ItemSpawnEpic.instance()
		get_parent().call_deferred("add_child", item2)
		get_parent().call_deferred("add_child", itemSpawnEpic)
		item2.global_position = $ItemLocation2.global_position
		var spawnerEffectPosition2 = $ItemLocation2.global_position
		spawnerEffectPosition2.y = -10
		itemSpawnEpic.global_position = spawnerEffectPosition2
		itemSpawnEpic.z_index = 1
		thirdItem = true
		timerSpawnDelay.start()
	else:
		randomNumber = randi() % itemsArray.size()
		var item3 = itemsArray[randomNumber].instance()
		thirdItem = false
		var itemSpawnNormal = ItemSpawnNormal.instance()
		get_parent().call_deferred("add_child", item3)
		get_parent().call_deferred("add_child", itemSpawnNormal)
		item3.global_position = $ItemLocation3.global_position
		var spawnerEffectPosition3 = $ItemLocation3.global_position
		spawnerEffectPosition3.y = -10
		itemSpawnNormal.global_position = spawnerEffectPosition3
		itemSpawnNormal.z_index = 1




func on_timeout_complete_reminder():
	if Global.traderPause:
		$Reminder.visible = true
