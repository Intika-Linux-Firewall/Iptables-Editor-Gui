#
# policycontrol.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

class PolicyControl < Gtk::HBox
	include GetText
	#
	def initialize(pol, changeHandler)
		super(false, 5)
		
		@handleChanges = changeHandler
		
		pack_start(Gtk::Label.new(_('Policy')), false, false, 3)
		
		@comboPol = Gtk::ComboBox.new
		pack_start(@comboPol, false, false)
		
		@comboPol.model = mdl = Gtk::ListStore.new(String)
		ativo = 0
		if pol == '-'
			#
			# cadeia definida pelo usuário - não há política definida
			# user defined chain - there is no policy defined
			itera = mdl.append
			itera[0] = 'N/A'
		else
			%w(ACCEPT DROP QUEUE RETURN).each_with_index do |op, i|
				itera = mdl.append
				itera[0] = op
				ativo = i if pol == op
			end
		end
		
		@comboPol.active_iter = mdl.get_iter(ativo.to_s)
		show_all
		
		@comboPol.signal_connect('changed') {|cb| @handleChanges.call if $rulesLoaded }
	end
	#
	def policy=(pol)
		@comboPol.model.each do |mdl, path, iter|
			if iter[0] == pol
				@comboPol.active_iter = iter
				break
			end
		end
	end
	#
	def policy
		@comboPol.active_text
	end
end

#
# policycontrol.rb - eof
