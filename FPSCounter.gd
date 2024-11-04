extends Label

func _process(_delta):
	var FPS=Engine.get_frames_per_second()
	text = "FPS: "+str(FPS)
