class_name UIHelpers

## Creates an input dialog which lets the user type into a [LineEdit] control and submit or cancel. You will need to manually hide and free the dialog when it has been submitted (this is to allow for error handling).
static func input_dialog(title: String = "", label_text: String = "", default_edit_text: String = "", on_submit: Callable = func(): pass, on_cancel: Callable = func(): pass) -> ConfirmationDialog:
	var line_edit: LineEdit = LineEdit.new()
	line_edit.text = default_edit_text
	var label: Label = Label.new()
	label.text = label_text
	var vertical_view: VBoxContainer = VBoxContainer.new()
	vertical_view.add_child(label)
	vertical_view.add_child(line_edit)

	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.dialog_hide_on_ok = false
	dialog.set_unparent_when_invisible(true)
	dialog.title = title
	dialog.add_child(vertical_view)

	dialog.canceled.connect(on_cancel)

	dialog.register_text_enter(line_edit)
	dialog.get_ok_button().pressed.connect(func():
		on_submit.call(dialog, line_edit.text)
	)
	line_edit.text_submitted.connect(func(new_text: String):
		on_submit.call(dialog, new_text)
	)
	return dialog

## Creates a confirmation dialog with the given label which lets the user submit or cancel. You will need to manually hide and free the dialog when it has been submitted (this is to allow for error handling).
static func confirm_dialog_wlabel(title: String = "", label_text: String = "", on_submit: Callable = func(): pass, on_cancel: Callable = func(): pass) -> ConfirmationDialog:
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.dialog_hide_on_ok = false
	dialog.set_unparent_when_invisible(true)
	dialog.title = title
	dialog.get_label().text = label_text
	dialog.get_ok_button().pressed.connect(func():
		on_submit.call(dialog)
	)
	dialog.canceled.connect(on_cancel)
	return dialog

## Creates a confirmation dialog with the given panel which lets the user submit or cancel. You will need to manually hide and free the dialog when it has been submitted (this is to allow for error handling).
static func confirm_dialog(title: String = "", panel: Control = null, on_submit: Callable = func(): pass, on_cancel: Callable = func(): pass) -> ConfirmationDialog:
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.dialog_hide_on_ok = false
	dialog.set_unparent_when_invisible(true)
	dialog.title = title
	if panel:
		dialog.add_child(panel)
	dialog.get_ok_button().pressed.connect(func():
		on_submit.call(dialog)
	)
	dialog.canceled.connect(on_cancel)
	return dialog

## Creates an instance of [OptionButton]. [param labels] is an array of type [String] and [param icons] is an array of type [Texture2D].
static func option_btn_wicons(labels: Array, initial_selection: int = -1, icons: Array = []) -> OptionButton:
	var has_icons: bool = icons != null && icons.size() > 0
	if has_icons:
		assert(labels.size() == icons.size(), "Parameter input error: labels array and icons array must have the same size")

	var option_btn: OptionButton = OptionButton.new()
	var types_menu: PopupMenu = option_btn.get_popup()
	for i in labels.size():
		if has_icons:
			types_menu.add_icon_item(icons[i], labels[i])
		else:
			types_menu.add_item(labels[i])
	option_btn.select(initial_selection)
	return option_btn