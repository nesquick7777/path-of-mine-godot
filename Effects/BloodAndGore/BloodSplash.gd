extends Particles2D

var timer = null
onready var bloodArray = [
	preload("res://Effects/BloodAndGore/Blood1.png"),
	preload("res://Effects/BloodAndGore/Blood2.png"),
	preload("res://Effects/BloodAndGore/Blood3.png"),
	preload("res://Effects/BloodAndGore/Blood4.png"),
	preload("res://Effects/BloodAndGore/Blood5.png")
]

onready var soundArray = [
	preload("res://Effects/BloodAndGore/2__blood-and-gore.wav"),
	preload("res://Effects/BloodAndGore/3__blood-and-gore.wav"),
	preload("res://Effects/BloodAndGore/1__blood-and-gore.wav"),
	preload("res://Effects/BloodAndGore/7__blood-and-gore.wav")
]

var randomNumber = 0

var isSilent = false
func noSound():
	isSilent = true

func _ready():
	randomize()
	randomNumber = randi() % 5
	self.texture = bloodArray[randomNumber]
	randomNumber = randi() % 4
	if !isSilent:
		if randomNumber == 3:
			$AudioStreamPlayer2D.volume_db = 20
			$AudioStreamPlayer2D.set_stream(soundArray[randomNumber])
			$AudioStreamPlayer2D.play(0.05)
		else:
			$AudioStreamPlayer2D.volume_db = 10
			$AudioStreamPlayer2D.set_stream(soundArray[randomNumber])
			$AudioStreamPlayer2D.play(0.05)
	emitting = true
	one_shot = true
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(2.5)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	timer.start()

func on_timeout_complete():
	queue_free()
