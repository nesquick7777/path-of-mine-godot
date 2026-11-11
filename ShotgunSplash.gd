extends Particles2D

var timer = null

func _ready():
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
