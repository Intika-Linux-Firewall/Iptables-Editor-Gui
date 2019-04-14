#
# rulespage.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

#
# Dependências internas
require 'policycontrol'

class RulesPage < Gtk::VBox
	attr_reader :list
	
	#
	def initialize(name, politica, handleSelection, handleChanges)
		super(false, 3)
		set_name name
		
		@policy = politica
		pack_start(@polCtl = PolicyControl.new(politica, handleChanges), false, false, 3)
		
		@handleSelection = handleSelection
		
		# adicionamos a janela rolante para controlar a visualização da lista
		# add the scroll window to control visualization of the list
		rol = Gtk::ScrolledWindow.new
		rol.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
		pack_start(rol)
		
		# adicionamos a "lista" que conterá as regras à janela rolante
		# add the "list" which will contain the rules to the scroll window
		rol.add(@list = RulesList.new(handleChanges))
		
		@list.signal_connect('cursor-changed') { @handleSelection.call }
		@list.selection.signal_connect('changed') { @handleSelection.call }
		
		# adicionamos um tratador para eventos de teclado
		# add an event handler for keyboard events
		signal_connect('key-release-event') {|tv, ev| handleKey(tv, ev) }
	end
	
	#
	# to_s
	# ----
	# atalho para list.to_s
	#
	# shortcut for list.to_s
	#
	def to_s
		list.to_s
	end
	
	#
	# selected_each
	# -------------
	# atalho para list.selection.selected_each
	#
	# shortcut for list.selection.selected_each
	#
	def selected_each(&l)
		list.selection.selected_each {|mdl, path, iter| l.call mdl, path, iter }
	end
	
	#
	# clear
	# -----
	# remove todas as regras desta cadeia
	#
	# remove all rules from this chain
	#
	def clear
		list.model.clear
		parent.pageChanged
	end
	
	#
	def handleKey(tv, ev)
		case ev.keyval
		when Gdk::Keyval::GDK_Escape
			# desselecionamos a linha atual e posicionamos o cursor no final da lista
			# deselect the current line and position the cursor at the end of the list
			sel = @list.selection
			sel.unselect_iter(sel.selected)
			@list.set_cursor(Gtk::TreePath.new('100000'), nil, false)
			
		when Gdk::Keyval::GDK_Return
			
		end
	end
	
	#
	# each
	# ----
	# atalho para list.model.each
	#
	# shortcut to list.model.each
	#
	def each(&l)
		list.model.each {|mdl, path, iter| l.call mdl, path, iter }
	end
	
	#
	def policy=(pol)
		@polCtl.policy = pol
	end
	
	#
	def policy
		@polCtl.policy
	end
	
	#
	def addRule(r)
		# se houver uma regra selecionada nesta cadeia,
		# inserimos a regra fornecida antes dela,
		# senão apensamos a regra fornecida ao final da lista
		#
		# if there is a rule selected in this chain,
		# insert the passed in rule before that,
		# otherwise append the passed in rule to the end of the list
		#
		if path = @list.cursor[0]
			iter = @list.model.get_iter(path)
			iter = @list.model.insert_before(iter)
		else
			iter = @list.model.append
		end
		
		r = r || ['All', '', '', 'All', '', '0.0.0.0/0', '0.0.0.0/0', 'Jump', 'ACCEPT']
		if r.class == String
			r = processStr r
		end
		
		r.each_with_index {|elem, i| iter[i] = elem }
		
		# retornamos o iterador referenciando a regra recém-inserida
		# return the iterator referencing the newly inserted rule
		iter
	end
	
	#
	def selectRule(i)
		@list.scroll_to_cell(i.path, nil, false, 0, 0)
		@list.set_cursor(i.path, nil, nil)
		@list.grab_focus
		
		@handleSelection.call
	end
	
	#
	def processStr(r)
		r = r.split(/\s/)
		# para cada item encontrado, extraímos e descartamos os campos relativos
		# for each found item, extract and discard related fields
		
		if i = r.index('-p')
			# definição de protocolo
			# protocol definition
			if r[i + 1] == '!'
				proto = 'But '
			else
				proto = ''
			end
			
			j = (r[i + 1] == '!') ? 3 : 2
			proto += r.slice!(i, j).last
		else
			proto = 'All'
		end
		
		if i = r.index('-f')
			# definição de fragmento de pacotes
			# packet fragment definition:
			j = 1
			if i > 0 && r[i - 1] == '!'
				i -= 1
				j = 2
			end
			r.slice!(i, j)
			frag = j == 2 ? 'Headers' : 'Fragments'
		else
			frag = 'All'
		end
		
		if i = r.index('-s')
			# definição de IP de origem
			# origination IP spec
			j = (r[i + 1] == '!') ? 3 : 2
			orig = r.slice!(i, j).drop(1).join(' ')
		else
			orig = '0.0.0.0/0'
		end
		
		if i = r.index('-d')
			# definição de IP de destino
			# destination IP spec
			j = (r[i + 1] == '!') ? 3 : 2
			dest = r.slice!(i, j).drop(1).join(' ')
		else
			dest = '0.0.0.0/0'
		end
		
		if i = r.index('-i')
			# especificação de interface de entrada
			# input interface spec
			j = (r[i + 1] == '!') ? 3 : 2
			ifin = r.slice!(i, j).drop(1).join(' ')
		else
			ifin = ''
		end
		
		if i = r.index('-o')
			# especificação de interface de saída
			# output interface spec
			j = (r[i + 1] == '!') ? 3 : 2
			ifout = r.slice!(i, j).drop(1).join(' ')
		else
			ifout = ''
		end
		
		if i = r.index('-j') || r.index('-g')
			acao = r[i] == '-j' ? 'Jump' : 'Goto'
			
			# instrução de salto (alvo) = "-j" ou "-g"
			# jump (target) instruction
			target = r.slice!(i, r.length - i).drop(1).join(' ')
			
			# caso especial: alvo TOS: convertemos os valores para símbolos
			# special case: TOS target: convert values to symbols
			if target.start_with? 'TOS'
				if ! (opt = target.scan(/0x([0-9a-f]{2})\/0x([0-9a-f]{2})/i).flatten).empty?
				
					case opt[0]
					when '10'
						opt = 'Minimize-Delay'
					when '08'
						opt = 'Maximize-Throughput'
					when '04'
						opt = 'Maximize-Reliability'
					when '02'
						opt = 'Minimize-Cost'
					when '00'
						opt = 'Normal-Service'
					end
					
					target.sub!(/0x([0-9a-f]{2})\/0x([0-9a-f]{2})/i, opt)
				end
				
			end
			
			puts "target #{target}" if $DEBUG
			
		else
			target = ''
			
		end
		
		# finalmente, possíveis especificações de critérios
		# finally, possible criteria specifications
		ok = false
		cond = r.join(' ').gsub(/(-m [^-m]+)/) {|s| if ok; "\n" + s; else; ok = true; s; end }
		
		return [proto, ifin, ifout, frag, cond, orig, dest, acao, target]
	end
	
end

#
# rulespage.rb - eof
