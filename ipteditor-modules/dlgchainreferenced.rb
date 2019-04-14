#
# dlgchainreferenced.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

class DlgChainReferenced < Gtk::Dialog
	include GetText
	
	def initialize(chain, s)
		super(
			_('Chain referenced'),
			nil,
			Gtk::Dialog::MODAL,
			[ Gtk::Stock::OK,    Gtk::Dialog::RESPONSE_OK ]
		)
		
		vbox.pack_start(Gtk::Label.new(chain), false, true, 5)
		vbox.pack_start(Gtk::Label.new(_('This chain is referenced by rules in the following chains')), false, true, 5)
		vbox.pack_start(sw = Gtk::ScrolledWindow.new, false, true, 5)
		
		sw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
		sw.add(txt = Gtk::TextView.new)
		txt.buffer.text = s.uniq.join("\n")
		txt.editable = false
		
		show_all
	end
end

#
# dlgchainreferenced.rb - eof
