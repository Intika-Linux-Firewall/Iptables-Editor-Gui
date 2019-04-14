#
# dlgconfirm.rb
#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

class DlgConfirm < Gtk::Dialog
	def initialize(msg)
		super(
			'IPTEditor',
			nil,
			Gtk::Dialog::MODAL,
			[Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK],
			[Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL]
		)
		vbox.pack_start(Gtk::Label.new(msg))
		show_all
	end
end

#
# dlgconfirm.rb - eof
