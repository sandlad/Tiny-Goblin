extends Node

@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 60.0
@export var spawn_rate_per_minute: float = 30.0
@export var wave_duration: float = 20.0
@export var break_intensity: float = 0.5

var time: float = 0.0

func _process(delta: float) -> void:
	# Ignorar se GameOver
	if GameManager.is_game_over: return
	time += delta
	
	# Dificuldade linear
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute* (time / 60.0)
	# Onda sinoidal para a variação 
	
	# Sistema de ondas (Dificuldade Exponencial, e com pausas) 
	var sin_wave = sin((time * TAU) / wave_duration) # PI = 3.14  0 <-> 2PI = TAU
	# MUITO IMPORTANTE E ÚTIL \/\/\/\/\/\/
	# Função pega uma variável, visualiza qual é seu min/max, e exporta o min/max desejado
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1.0)
	
	spawn_rate *= wave_factor
	
	# Aplicar dificuldade
	mob_spawner.mobs_per_minute = spawn_rate
