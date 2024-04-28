class_name UIHelpers

## Creates an input dialog which lets the user type into a [LineEdit] control and submit or cancel. [param label_text] is currently not working. You will need to manually hide and free the dialog
## when it has been submitted (this is to allow for error handling).
static func create_input_dialog(title: String = "", label_text: String = "", default_edit_text: String = "", on_submit: Callable = func(): pass, on_cancel: Callable = func(): pass) -> ConfirmationDialog:
	var line_edit: LineEdit = LineEdit.new()
	line_edit.text = default_edit_text

	var input_dialog: ConfirmationDialog = ConfirmationDialog.new()
	input_dialog.dialog_hide_on_ok = false
	input_dialog.set_unparent_when_invisible(true)
	input_dialog.title = title
	input_dialog.get_label().text = label_text
	input_dialog.add_child(line_edit)

	input_dialog.canceled.connect(on_cancel)

	input_dialog.register_text_enter(line_edit)
	input_dialog.get_ok_button().pressed.connect(func():
		on_submit.call(input_dialog, line_edit.text)
	)
	line_edit.text_submitted.connect(func(new_text: String):
		on_submit.call(input_dialog, new_text)
	)
	return input_dialog

## Creates an confirmation dialog which lets the user submit or cancel. You will need to manually hide and free the dialog when it has been submitted (this is to allow for error handling).
static func create_confirmation_dialog(title: String = "", label_text: String = "", on_submit: Callable = func(): pass, on_cancel: Callable = func(): pass) -> ConfirmationDialog:
	var confirmation_dialog: ConfirmationDialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_hide_on_ok = false
	confirmation_dialog.set_unparent_when_invisible(true)
	confirmation_dialog.title = title
	confirmation_dialog.get_label().text = label_text
	confirmation_dialog.get_ok_button().pressed.connect(func():
		on_submit.call(confirmation_dialog)
	)
	confirmation_dialog.canceled.connect(on_cancel)
	return confirmation_dialog