#
# dlgcriteria.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

#
# Dependências internas
require 'criteria'

class DlgCriteria < Gtk::Dialog
	include Criteria, GetText
	
	def initialize(s)
		super(
			_('Criteria edition'),
			nil,
			Gtk::Dialog::MODAL,
			[ Gtk::Stock::OK,    Gtk::Dialog::RESPONSE_OK ],
			[ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ]
		)
		set_default_size(400, 200)
		
		vbox.spacing = 5
		vbox.pack_start(@edita = Gtk::Entry.new, false, true)
		
		@edita.text = s
		ok = false
		@comps = s.gsub(/(-m [^-m]+)/) {|s| if ok; "\n" + s; else; ok = true; s; end }.split("\n")
		vbox.pack_start(Gtk::HSeparator.new)
		
		iniCriteriaList
		addControls
		
		show_all
		@parms[1].hide
	end
	
	#
	def text
		@edita.text
	end
	
	#
	def iniCriteriaList
		@lops = {}
		@lcrit = Gtk::ListStore.new(String)
		
		CRITERIA.keys.sort.each do |crit|
			# adicionamos o critério à lista de critérios
			# add criterium to list of criteria
			@lcrit.append[0] = crit
		end
		
	end
	
	#
	def addControls
		vbox.pack_start(tbl = Gtk::Table.new(2, 6))
		
		# adicionamos a caixa de seleção de critério
		tbl.attach(lbl = Gtk::Label.new(_('Module')), 0, 1, 1, 2, Gtk::FILL, Gtk::EXPAND | Gtk::FILL, 3)
		lbl.xalign = 0
		
		tbl.attach(@cbCrits = cb = Gtk::ComboBox.new, 1, 2, 1, 2)
		cb.model = @lcrit
		cb.signal_connect('changed') {|cs| fillOptions(cs) }
		
		# adicionamos a caixa de seleção de opções para o critério selecionado
		tbl.attach(lbl = Gtk::Label.new(_('Options')), 0, 1, 2, 3, Gtk::FILL, Gtk::EXPAND | Gtk::FILL, 3)
		lbl.xalign = 0

		tbl.attach(qh = Gtk::HBox.new(false, 2), 1, 2, 2, 3)
		qh.pack_start(@neg = Gtk::CheckButton.new('!'), false, false, 2)
		@neg.sensitive = false
		qh.pack_start(@cbOps = cb = Gtk::ComboBox.new)
		@cbOps.model = Gtk::ListStore.new(String, TrueClass, TrueClass, Array)
		cb.signal_connect('changed') {|cs| selOption(cs) }
		
		# adicionamos dois controles para entrada de parâmetros relativos à opção selecionada
		tbl.attach(lbl = Gtk::Label.new(_('Parameters')), 0, 1, 3, 4, Gtk::FILL, Gtk::EXPAND | Gtk::FILL, 3)
		lbl.xalign = 0

		@parms = []
		tbl.attach(@parms[0] = Gtk::Entry.new, 1, 2, 3, 4)
		tbl.attach(@parms[1] = Gtk::ComboBox.new, 1, 2, 3, 4)
		@parms[0].sensitive = @parms[1].sensitive = false
		
		# adicionamos um botão para inserção deste critério na caixa de edição
		tbl.attach(bt = Gtk::Button.new(Gtk::Stock::ADD), 0, 2, 4, 5)
		bt.signal_connect('clicked') { insertOption }
	end
	
	#
	# fillOptions
	# -----------
	#
	def fillOptions(cs)
		@cbOps.model.clear
		CRITERIA[cs.active_text].sort.each do |op|
			s = op
			# verificamos a indicação de negação da opção
			# check the option negation indication
			s = s.slice(1, s.length) if (chave = s.start_with? '!')
			
			# verificamos a indicação de parâmetros
			# check parameters indication
			if temParms = s.include?('*')
				# opção inclui parâmetros
				# option has parameters
				s, *lp = s.split('*')
			else
				# opção não inclui parâmetros
				# option has no parameters
				lp = nil
			end
			
			iteraOp = @cbOps.model.append
			iteraOp[0] = s
			iteraOp[1] = chave
			iteraOp[2] = temParms
			iteraOp[3] = lp
		end
		
		numops = CRITERIA[cs.active_text].length
		
		if numops == 0
			# módulo não tem opções
			# module has no options
			@cbOps.sensitive = false
			clearOption(false, false)
			
		else
			
			if numops == 1
				# módulo tem uma única opção
				# module has only one option
				@cbOps.active = 0
				
			else
				# módulo tem mais de uma opção
				# module has more than one option
				@cbOps.active = -1
				selOption(@cbOps)
				
			end
			
		end
		
		@cbOps.show_all
		
	end
	
	#
	# selOption
	# ---------
	#
	def selOption(cs)
		puts "selOption(#{cs.active_text})" if $DEBUG
	
		if cs.active != -1
		
			if cs.active_iter[3] && (cs.active_iter[3].count > 0)
				@parms[0].hide
				@parms[1].show
				@parms[1].model = m = Gtk::ListStore.new(String)
				cs.active_iter[3].each do |so|
					iso = m.append
					iso[0] = so
				end
				
			else
				@parms[1].hide
				@parms[0].show
				
			end
			
			clearOption(cs.active_iter[1], cs.active_iter[2])
			
		else
			@parms[1].hide
			@parms[0].show
			clearOption(false, false)
			
		end
		
	end
	
	#
	# clearOption
	# -----------
	#
	def clearOption(neg, parms)
		@neg.active = false
		@neg.sensitive = neg
		
		if @parms[0].visible?
			@parms[0].text = ''
			@parms[0].sensitive = parms
		else
			@parms[1].active = -1
			@parms[1].sensitive = parms
		end
	end
	
	#
	# insertOption
	# ------------
	#
	def insertOption
		txt = '-m ' + @cbCrits.active_text
		
		# verificamos se o módulo não já está presente nos critérios
		# check to see if the module isn't yet present in the criteria
		i = @comps.index {|c| c.start_with? txt }
		
		if i
			# módulo já está presente: apenas acrescentamos a opção
			# module already present: just add the option
			if @cbOps.active != -1
				txt = (@neg.active? ? ' !' : '') + ' --' + @cbOps.active_text
				
				if @parms[0].visible?
					
					if ! @parms[0].text.empty?
						txt += ' ' + @parms[0].text
					end
					
				else
					
					if @parms[1].active != -1
						txt += ' ' + @parms[1].active_text
					end
					
				end
		
			end
			
			@comps[i] += txt
		else
			# módulo não presente: adicionamos o conjunto módulo mais opção
			# module not present: add both module and option
			if @cbOps.active != -1
				txt += (@neg.active? ? ' !' : '') + ' --' + @cbOps.active_text
				
				if @parms[0].visible?
				
					if ! @parms[0].text.empty?
						txt += ' ' + @parms[0].text
					end
					
				else
					
					if @parms[1].active != -1
						txt += ' ' + @parms[1].active_text
					end
					
				end
				
			end
			
			@comps << txt
			
		end
		
		@edita.text = @comps.join(' ')
		
	end
	
end


#
# dlgcriteria.rb - eof
