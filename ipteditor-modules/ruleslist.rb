#
# ruleslist.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

#
# Dependências internas
require 'dlgcriteria'
require 'dlgtarget'

class RulesList < Gtk::TreeView
	def initialize(handleChanges)
		super()
		
		@handleChanges = handleChanges
		
		createModels
		addCols
		
		set_rules_hint true
		set_sensitive true
		selection.mode = Gtk::SELECTION_MULTIPLE
		
		signal_connect('row-activated') {|tv, tp, col| editaCelula(tv, tp, col) }
	end
	
	#
	def createModels
		@modelos = {}
		@modelos['prt'] = m = Gtk::ListStore.new(String)
		['tcp', 'udp', 'icmp', 'But tcp', 'But udp', 'But icmp', 'All'].each {|p| m.append[0] = p }
		@modelos['if'] = m = Gtk::ListStore.new(String)
		File.open('/proc/net/dev', 'r') do |arq|
			while l = arq.gets
				if ! l.scan(/(^\s*\w+):/).empty?
					m.append[0] = $1.strip
				end
			end
		end
		@modelos['frg'] = m = Gtk::ListStore.new(String)
		%w(All Fragments Headers).each {|p| m.append[0] = p }
		@modelos['act'] = m = Gtk::ListStore.new(String)
		%w(Jump Goto).each {|p| m.append[0] = p }
	end
	
	#
	def addCols
		# "cols" é uma matriz de matrizes com a descrição das colunas
		# [0] = Nome
		# [1] = Título
		# [2] = Tipo (combo ou text)
		# [3] = Coluna editável
		[
			['prt', 'Protocol', 'c', true],
			['ifi', 'In Interface', 'c', true],
			['ifo', 'Out Interface', 'c', true],
			['frg', 'Fragment', 'c', true],
			['crt', 'Criteria', 't', false],
			['org', 'Origin', 't', true],
			['dst', 'Destination', 't', true],
			['act', 'Action', 'c', true],
			['tgt', 'Target', 't', false]
		].each_with_index do |c, i|
			
			case c[2]
			when 't'
				rndr = Gtk::CellRendererText.new
				rndr.editable = c[3]
				
				if c[0] == 'crt'
					rndr.wrap_mode = Pango::WRAP_WORD_CHAR
				end
				
				rndr.signal_connect('edited') {|comp, path, txt| mudaTexto(path, txt, i) }
				col = Gtk::TreeViewColumn.new(c[1], rndr, 'text' => i)
				
			when 'c'
				rndr = Gtk::CellRendererCombo.new
				rndr.model = @modelos[c[0].slice(0, 2)]
				rndr.text_column = 0
				rndr.editable = c[3]
				rndr.has_entry = false
				rndr.signal_connect('edited') {|comp, path, txt| mudaTexto(path, txt, i) }
				col = Gtk::TreeViewColumn.new(c[1], rndr, 'text' => i)
				
			end
			
			append_column(col)
			col.set_builder_name c[0]
			# col.set_name c[0] # Old GTK2
			# builder_name/#set_builder_name
			col.resizable = true
			
		end
		
		set_model Gtk::ListStore.new(String, String, String, String, String, String, String, String, String)
		
		# conecta a sinalização de eventos
		# connects signaling of events
		model.signal_connect('row-changed') { @handleChanges.call if $rulesLoaded }
		model.signal_connect('row-inserted') { @handleChanges.call if $rulesLoaded }
		model.signal_connect('row-deleted') { @handleChanges.call if $rulesLoaded }
	end
	
	#
	def mudaTexto(path, txt, i)
		itera = model.get_iter(path)
		itera[i] = txt
		#@handleChanges.call
	end
	
	#
	# unblockSignals
	# --------------
	# habilita a sinalização de eventos ocorridos na lista
	#
	# enables signaling of events occurred in the list
	#
	#def unblockSignals
	#	puts "unblocking signals for #{parent.parent.name}" if $DEBUG
	#	@signals.each {|s| model.signal_handler_unblock s }
	#end
	
	#
	# blockSignals
	# -----------------
	# desabilita a sinalização de eventos ocorridos na lista
	#
	# disables signaling of events occurred in the list
	#
	#def blockSignals
	#	puts "blocking signals for #{parent.parent.name}" if $DEBUG
	#	@signals.each {|s| model.signal_handler_block s }
	#end
	
	#
	def editaCelula(tv, tp, col)
		val = col.cell_renderers[0].text
		puts "row-activated col #{col.title} da linha #{tp.to_str} - valor: #{val}" if $DEBUG
		
		case col.name
		when 'crt'
			indiceCol = 4
			dlg = DlgCriteria.new(val.gsub(/\n/, ''))
			
		when 'tgt'
			puts "editando alvo - parent = #{parent.parent.parent}" if $DEBUG
			chainsNotebook = parent.parent.parent
			indiceCol = 8
			dlg = DlgTarget.new(val, chainsNotebook.targetsModel)
			
		end
		
		dlg.run do |r|
			if r == Gtk::Dialog::RESPONSE_OK
				text = dlg.text
				
				if indiceCol == 4
					ok = false
					text = text.gsub(/(-m\s[^-m\s]+)/) {|s| if ok; "\n" + s; else; ok = true; s; end }
				end
				
				mudaTexto(tp, text, indiceCol)
			end
		end
		
		dlg.destroy
	end
	
	#
	# to_s
	# ----
	# serializa as regras desta cadeia no formato reconhecido por "iptables-restore"
	#
	# serializes this chain rules in the format recognized by "iptables-restore"
	#
	def to_s
		s = []
		
		model.each do |mdl, path, iter|
			txt = "-A #{parent.parent.name}"
			txt += ' -p ' + iter[0].sub('But', '!') if iter[0] != 'All'
			txt += " -i #{iter[1]}" if ! iter[1].empty?
			txt += " -o #{iter[2]}" if ! iter[2].empty?
			case iter[3]
			when 'Fragments'
				txt += ' -f'
			when 'Headers'
				txt += ' ! -f'
			end
			txt += ' ' + iter[4].gsub(/\n/, ' ') if ! iter[4].empty?
			txt += " -s #{iter[5]}" if iter[5] != '0.0.0.0/0'
			txt += " -d #{iter[6]}" if iter[6] != '0.0.0.0/0'
			if iter[7] == 'Jump'
				txt += ' -j'
			else
				txt += ' -g'
			end
			txt += " #{iter[8]}" if ! iter[8].empty?
			s << txt
		end
		
		if s.length != 0
			s.compact.join("\n") + "\n"
		else
			''
		end
	end
	
end

#
# ruleslist.rb - eof
