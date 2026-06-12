extends SceneTree

const TestEffectResolver = preload("res://tests/test_effect_resolver.gd")
const TestBattleController = preload("res://tests/test_battle_controller.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	failures.append_array(TestEffectResolver.new().run())
	failures.append_array(TestBattleController.new().run())
	_write_results(failures)
	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _write_results(failures: Array[String]) -> void:
	var output_path := ProjectSettings.globalize_path("res://test-results.txt")
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		return
	if failures.is_empty():
		file.store_line("ALL TESTS PASSED")
	else:
		file.store_line("TESTS FAILED")
		for failure in failures:
			file.store_line(failure)
