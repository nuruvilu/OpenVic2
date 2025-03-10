extends GridContainer

const RATIO_FOR_LINEAR = 100

var _slider_dictionary := {}

func get_db_as_volume_value(db : float) -> float:
	# db_to_linear produces a float between 0 and 1 from a db value
	return db_to_linear(db) * RATIO_FOR_LINEAR

func get_volume_value_as_db(value : float) -> float:
	# linear_to_db consumes a float between 0 and 1 to produce the db value
	return linear_to_db(value / RATIO_FOR_LINEAR)

func add_volume_column(bus_name : StringName, bus_index : int) -> HSlider:
	var volume_label := Label.new()
	volume_label.text = bus_name + " Volume"
	add_child(volume_label)

	var volume_slider := SettingHSlider.new()
	volume_slider.section_name = "Audio"
	volume_slider.setting_name = volume_label.text
	volume_slider.custom_minimum_size = Vector2(290, 0)
	volume_slider.size_flags_vertical = Control.SIZE_FILL
	volume_slider.min_value = 0
	volume_slider.default_value = 100
	volume_slider.max_value = 120 # 120 so volume can be boosted somewhat
	volume_slider.value_changed.connect(_on_slider_value_changed.bind(bus_index))
	add_child(volume_slider)

	_slider_dictionary[volume_label.text] = volume_slider
	return volume_slider

func _ready():
	for bus_index in AudioServer.bus_count:
		add_volume_column(AudioServer.get_bus_name(bus_index), bus_index)

func _on_slider_value_changed(value : float, bus_index : int) -> void:
	AudioServer.set_bus_volume_db(bus_index, get_volume_value_as_db(value))


func _on_options_menu_load_settings(load_file : ConfigFile):
	for volume_label_text in _slider_dictionary:
		_slider_dictionary[volume_label_text].load_setting(load_file)


func _on_options_menu_save_settings(save_file : ConfigFile):
	for volume_label_text in _slider_dictionary:
		_slider_dictionary[volume_label_text].save_setting(save_file)


func _on_options_menu_reset_settings():
	for volume_label_text in _slider_dictionary:
		_slider_dictionary[volume_label_text].reset_setting()
