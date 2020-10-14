#
# iptenotebook.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

class IPTENotebook < Gtk::Notebook
	include GetText
	
	#
	def initialize
		super
		@paginas = []
	end

	#
	def each(&l)
		id = nil
		i = 0
		p = get_nth_page i
		while p
			id = p.object_id if id != p.object_id
			l.call p
			p = get_nth_page i
			# esta verificação é necessária porque o objeto atual pode
			# ter sido removido durante esta iteração
			# this check is necessary because the current object may
			# have been removed during this iteration
			if p.object_id == id
				i += 1
				p = get_nth_page i
			end
		end
	end

	#
	def each_with_index(&l)
		id = nil
		i = 0
		p = get_nth_page i
		while p
			id = p.object_id if id != p.object_id
			l.call p, i
			p = get_nth_page i
			# esta verificação é necessária porque o objeto atual pode
			# ter sido removido durante esta iteração
			# this check is necessary because the current object may
			# have been removed during this iteration
			if p.object_id == id
				i += 1
				p = get_nth_page i
			end
		end
	end
	
	#
	def pageChanged?(num)
		get_tab_label(get_nth_page(num)).changed?
	end
	
	#
	def pageChanged
		if $rulesLoaded
			puts "setting page changed for #{name}"
			get_tab_label(get_nth_page(page)).changed
			$changed = true
		end
	end
	
	#
	# setCurPage
	# ----------
	# define a página atual, trazendo-a para a frente, neste caderno
	#
	# set the current page, bringing it to the top, in this notebook
	#
	def setCurPage(p)
		case p.class.to_s
		when 'String'
			i = @paginas.index(p)
		when 'Integer'
			i = p
		else
			i = nil
		end
		
		puts "alternando para a página #{i} de #{name}" if $DEBUG
		
		if i
			set_page i
			get_nth_page page
		else
			nil
		end
	end
	
	#
	# pageTitle
	# ---------
	# retorna o nome da página referida por "num",
	# ou o da página atual, se num for nil
	#
	# return the name of the page referred by "num"
	# or that of the current page, if num is nil
	#
	def pageTitle(num = nil)
		@paginas[num || page]
	end
	
	#
	# curPage
	# -------
	# retorna a página atual
	#
	# return the current page
	#
	def curPage
		get_nth_page page
	end

	#
	# setPageForName
	# --------------
	# posiciona e retorna a página explicitada por "name"
	#
	# set and return the page named by "name"
	#
	def setPageForName(name)
		if i = @paginas.index(name)
			set_page i
			i = get_nth_page page
		end
		
		i
	end

	#
	# getPageForName
	# --------------
	# retorna a página referida por "name",
	# sem trazê-la para a frente no caderno
	#
	# return the page referred to by "name",
	# without bringing it to top
	#
	def getPageForName(name)
		get_nth_page @paginas.index(name)
	end
	
	#
	# hasPage?
	# --------
	# informa (verdadeiro ou falso) se a página referida por "name"
	# existe neste caderno
	#
	# tell (true or false) if the page referred to by "name"
	# exists in this notebook
	#
	def hasPage?(nome)
		@paginas.index(nome) != nil
	end
end

#
# iptenotebook.rb - eof
