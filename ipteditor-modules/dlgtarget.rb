#
# dlgtarget.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

#
# Dependências internas
require 'targets'

class DlgTarget < Gtk::Dialog
	include Targets, GetText
	
	def initialize(s, mdl)
		super(
			_("Target edition"),
			nil,
			Gtk::Dialog::MODAL,
			[Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK],
			[Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL]
		)
		set_default_size(400, 200)
		
		vbox.spacing = 5
		
		vbox.pack_start(@edita = Gtk::Entry.new, false, true)
		@edita.text = s
		ok = false
		
		vbox.pack_start(Gtk::HSeparator.new)
		
		initTargetList
		addTargets
		
		show_all
		@parms[1].hide
		show_all
	end
	#
	def texto
		@edita.text
	end
	#
	def initTargetList
		@lops = {}
		@ltgt = Gtk::ListStore.new(String)
		TARGETS.keys.sort.each do |tgt|
			# adicionamos o target à lista de targets
			# add target to list of targets
			@ltgt.append[0] = tgt
		end
	end
	#
	def addTargets
		vbox.pack_start(tbl = Gtk::Table.new(2, 6))
		# adicionamos a caixa de seleção de target
		# add target selection box
		tbl.attach(Gtk::Label.new('Target'), 0, 1, 1, 2)
		
		tbl.attach(@cbTgts = cb = Gtk::ComboBox.new, 1, 2, 1, 2)
		cb.model = @ltgt
		cb.signal_connect('changed') {|cs| preencheOpcoes(cs) }
		
		# adicionamos a caixa de seleção de opções para o target selecionado
		# add options selection box for the selected target
		tbl.attach(Gtk::Label.new('Options'), 0, 1, 2, 3)
		tbl.attach(qh = Gtk::HBox.new(false, 2), 1, 2, 2, 3)
		qh.pack_start(@cbOps = cb = Gtk::ComboBox.new)
		@cbOps.model = Gtk::ListStore.new(String, TrueClass, TrueClass, Array)
		cb.signal_connect('changed') {|cs| selOpcao(cs) }
		
		# adicionamos dois controles para entrada de parâmetros relativos à opção selecionada
		tbl.attach(Gtk::Label.new('Parameters'), 0, 1, 3, 4)
		@parms = []
		tbl.attach(@parms[0] = Gtk::Entry.new, 1, 2, 3, 4)
		tbl.attach(@parms[1] = Gtk::ComboBox.new, 1, 2, 3, 4)
		@parms[0].sensitive = @parms[1].sensitive = false
		
		# adicionamos um botão para inserção deste critério na caixa de edição
		tbl.attach(bt = Gtk::Button.new('Set'), 0, 2, 4, 5)
		bt.signal_connect('clicked') { insereOpcao }
	end
	#
	def preencheOpcoes(cs)
		@cbOps.model.clear
		TARGETS[cs.active_text].sort.each do |op|
			s = op
			
			# verificamos a indicação de negação da opção
			s = s.slice(1, s.length) if (chave = s.start_with? '!')
			
			# verificamos a indicação de parâmetros
			if temParms = s.include?('*')
				
				# opção inclui parâmetros
				s, *lp = s.split('*')
			else
				
				# opção não inclui parâmetros
				lp = nil
			end
			
			iteraOp = @cbOps.model.append
			iteraOp[0] = s
			iteraOp[1] = chave
			iteraOp[2] = temParms
			iteraOp[3] = lp
		end
		
		numops = TARGETS[cs.active_text].length
		
		if numops == 0
			# módulo não tem opções
			@cbOps.sensitive = false
			limpaOpcao(false, false)
		else
		
			if numops == 1
				# módulo tem uma única opção
				@cbOps.active = 0
			else
				# módulo tem mais de uma opção
				@cbOps.active = -1
				selOpcao(@cbOps)
			end
		end
		
		@cbOps.show_all
		
	end
	#
	def selOpcao(cs)
		puts "selOpcao(#{cs.active_text})" if $DEBUG
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
			limpaOpcao(cs.active_iter[1], cs.active_iter[2])
		else
			@parms[1].hide
			@parms[0].show
			limpaOpcao(false, false)
		end
	end
	#
	def limpaOpcao(negacao, parms)
		if @parms[0].visible?
			@parms[0].text = ''
			@parms[0].sensitive = parms
		else
			@parms[1].active = -1
			@parms[1].sensitive = parms
		end
	end
	#
	def insereOpcao
		txt = @cbTgts.active_text
		if @edita.text.start_with? txt
			# target já está definido: apenas acrescentamos a opção
			# target already set: just add option
			txt = @edita.text
			
			if @cbOps.active != -1
				txt += ' --' + @cbOps.active_text
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
		else
			# target diferente: definimo-lo junto com a opção
			if @cbOps.active != -1
				txt += ' --' + @cbOps.active_text
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
		end
		@edita.text = txt
	end
end

#
# dlgtarget.rb - eof
