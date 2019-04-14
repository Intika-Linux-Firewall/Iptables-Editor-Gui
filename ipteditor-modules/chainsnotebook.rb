#
# chainsnotebook.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

#
# Dependências internas
require 'label'

class ChainsNotebook < IPTENotebook
	attr_reader :targetsModel
	#
	def initialize(name)
		super()
		set_name(name)

		@targetsModel = []
	end

	#
	# findRefs
	# --------
	# retorna uma matriz com os nomes das cadeias em que
	# alguma regra referencie a cadeia especificada
	#
	# return an array with the names of the chains from which
	# the specified chain name is referenced by some rule as being a target
	#
	def findRefs(name)
		refs = []
		
		each do |chain|
			if chain.name != name
				puts "procurando referências na cadeia #{chain.name}" if $DEBUG
				chain.each {|mdl, path, iter| refs << chain.name if iter[8] == name }
			end
		end
		
		refs
	end
	
	#
	# addChain
	# --------
	# adiciona uma página (aba) a este caderno (tabela), referente à cadeia especificada,
	# somente se ela não já estiver presente
	#
	# add a page (tab) to this notebook, refering to the specified chain,
	# only if it is not yet present
	#
	def addChain(nome, pol, handleSelection)
		puts "adicionando cadeia #{nome}" if $DEBUG
		
		if i = @paginas.index(nome)
			(i = setCurPage(i)).policy = pol
		else
			append_page(rp = RulesPage.new(nome, pol, handleSelection, method(:pageChanged)), Label.new(nome))
			show_all

			@targetsModel << nome if pol == '-'
			@paginas << nome

			i = setCurPage(n_pages - 1)
		end
		
		i
	end
	
	#
	# remove_page
	# -----------
	#
	def remove_page(num)
		super(num)
		@paginas.slice!(num, 1)
		parent.pageChanged
	end
	
	#
	# pageChanged
	# -----------
	# estende a funcionalidade de IPTENotebook::pageChanged
	#
	# extends IPTENotebook::pageChanged
	#
	def pageChanged
		super
		parent.pageChanged if $rulesLoaded
	end
	
	#
	# setApplied
	# ----------
	# limpa a indicação de não aplicado em todas as cadeias;
	# retorna "self", permitindo o encadeamento de métodos
	#
	# clear the not applied indication for all chains;
	# return "self", providing for methods chaining
	#
	def setApplied
		0.upto(n_pages - 1) {|i| get_tab_label(get_nth_page(i)).applied }
		self
	end
	
	#
	# setSaved
	# --------
	# limpa a indicação de não salvo em todas as cadeias;
	# retorna "self", permitindo o encadeamento de métodos
	#
	# clear the not saved indication for all chains;
	# return "self", providing for methods chaining
	#
	def setSaved
		0.upto(n_pages - 1) {|i| get_tab_label(get_nth_page(i)).saved }
		self
	end
	
	#
	# addRule
	# -------
	# adiciona uma regra à cadeia da página selecionada;
	# se o parâmetro correspondente "r" for nulo, uma regra omissiva será adicionada
	#
	# adds a rule to the selected page's chain;
	# if the corresponding parameter "r" is nil, a default rule will be added
	#
	def addRule(r = nil, changeState = false)
		rp = get_nth_page(page)
		iter = rp.addRule(r)
		
		get_tab_label(rp).changed if changeState
		
		iter
	end
	
end

#
# chainsnotebook.rb - eof
