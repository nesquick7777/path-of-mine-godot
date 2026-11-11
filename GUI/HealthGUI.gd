extends Control

var maxHearts = 3 setget set_max_hearts
var hearts = 3 setget set_hearts

var hearts2 = 10 setget set_hearts2
var maxHearts2 = 10 setget set_max_hearts2

onready var heartUIFull = $PlayerHP/HeartUIFull
onready var heartUIEmpty = $PlayerHP/HeartUIEmpty
onready var obeliskHP = $ObeliskHealth/ObeliskHP

func set_max_hearts(value):
	maxHearts = max(value, 1)
	self.hearts = min(hearts, maxHearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = maxHearts * 16

func set_hearts(value):
	hearts = clamp(value, 0 , maxHearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts *16

func set_max_hearts2(value2):
	maxHearts2 = max(value2, 1)
	self.hearts2 = min(hearts2, maxHearts2)

func set_hearts2(value2):
	hearts2 = clamp(value2, 0 , maxHearts2)
	if obeliskHP != null:
		obeliskHP.rect_size.x = hearts2 * 2.6

var timer = null
var coolDownTimer = null
func _ready():
	coolDownTimer = Timer.new()
	coolDownTimer.set_one_shot(true)
	coolDownTimer.set_wait_time(10)
	coolDownTimer.connect("timeout",self,"on_timeout_complete_CD")
	add_child(coolDownTimer)
	
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(3)
	timer.connect("timeout",self,"on_timeout_complete")
	add_child(timer)
	self.maxHearts = PlayerStats.maxHealth
	self.hearts = PlayerStats.hearts
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	self.maxHearts2 = ObeliskStats.maxHearts2
	self.hearts2 = ObeliskStats.hearts2
	ObeliskStats.connect("health_changed2", self, "set_hearts2")
	ObeliskStats.connect("max_health_changed2", self, "set_max_hearts2")
	$DayCount.text ="         "+Global.stringDay + "\nDefend the Obelisk!"
	timer.start()

func on_timeout_complete_CD():
	$CoolDown.text = ""

var firstTime = true
func on_timeout_complete():
	if firstTime:
		#$Wave1.play(0.0)
		Global.stringDay = Global.dayCount
		$DayCount.text = ""
		firstTime = false
	else:
		$DayCount.text = ""
		Global.stringDay = Global.dayCount

func _physics_process(delta):
	if coolDownTimer.time_left > 0:
		$CoolDown.text = str(int(coolDownTimer.time_left))
	$NumberOfCoins.text = ":" + str(Global.playerCoins)
	if Global.stringDay != Global.dayCount:
		if $Wave2.playing == false:
			#$Wave1.stop()
			#$Wave2.play(0.0)
			pass
		timer.start()
		$DayCount.text = "       "+Global.dayCount + "\nTrader is Coming!"
		Global.stringDay = Global.dayCount

func itemTexture(itemNumber):
	match itemNumber:
		1:
			$Item.texture = preload("res://Items/BookOfTransformation/BookOfTransformation.png")
			$Item.scale.x = 1
			$Item.scale.y = 1
		2:
			$Item.texture = preload("res://Items/HourGlass/HourGlass.png")
			$Item.scale.x = 0.3
			$Item.scale.y = 0.3
		3:
			$Item.texture = preload("res://Items/LightningOrb/LightningOrbIcon.png")
			$Item.scale.x = 1
			$Item.scale.y = 1

func startCDTimer(duration):
	coolDownTimer.set_wait_time(duration)
	coolDownTimer.start()
