extends SceneTree

const TestEffectResolver = preload("res://tests/test_effect_resolver.gd")
const TestBattleController = preload("res://tests/test_battle_controller.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	failures.append_array(TestEffectResolver.new().run())
	failures.append_array(TestBattleController.new().run())
	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
