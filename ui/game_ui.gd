extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel
@onready var dead_label: Label = %DeadLabel

func _process(delta: float):
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter)
	dead_label.text = str(GameManager.monsters_defeated_counter)

