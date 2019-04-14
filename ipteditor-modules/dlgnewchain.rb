#
# dlgnewchain.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

class DlgNewChain < Gtk::Dialog
	include GetText
	
	def initialize
		super(
			_('New chain'),
			nil,
			Gtk::Dialog::MODAL,
			[ Gtk::Stock::OK,    Gtk::Dialog::RESPONSE_OK ],
			[ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ]
		)
		
		vbox.pack_start(Gtk::Label.new(_('Enter the name for the new chain')), false, true, 5)
		vbox.pack_start(@text = Gtk::Entry.new, false, true, 5)
		
		show_all
	end
	
	#
	def text
		@text.text
	end
end

#
# dlgnewchain.rb - eof
