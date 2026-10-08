extends Node
var score = 0
@onready var l: Label = %Label4
func add_point():
	score +=1
	l.text = "hii you sored" + str(score) +"coins"
	
