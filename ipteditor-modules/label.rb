#
# label.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

class Label < Gtk::HBox
	#
	def initialize(s)
		super(false, 3)
		
		# definimos o estado inicial do led como verdadeiro, indicando nenhuma alteração
		# set led's initial state to be true, indicating no change
		@applied = @saved = true
		
		# definimos as cores a serem usadas
		# define the colors to be used
		@green = Gdk::Color.new(0, 50000, 0)
		@red = Gdk::Color.new(50000, 0, 0)
		@yellow = Gdk::Color.new(60000, 60000, 0)
		
		# criamos o "led"
		# create the "led"
		@led = Gtk::DrawingArea.new
		@led.set_size_request(10, 20)
		@led.signal_connect('expose_event') {|led, ev| led_expose_event(led, ev) }
		
		pack_start(@led, false, false)
		
		# criamos a etiqueta
		# create the label
		@label = Gtk::Label.new(s)
		
		pack_start(@label)
		
		show_all
	end
	
	#
	def text
		@label.text
	end
	
	#
	def led_expose_event(led, ev)
		
		if ev.region.empty?
			puts "pintura desnecessária para este led" if $DEBUG
		else
			if ev.window.state != led.state
				w = ev.window
				alloc = led.allocation
				
				# pintamos o plano de fundo do led
				# paint the led background
				w.draw_rectangle(led.style.bg_gc(led.state), true, 0, 0, alloc.width, alloc.height)
				
				# pintamos o led
				# draw the led
				pc = led.style.fg_gc(led.state).foreground
				led.style.fg_gc(led.state).rgb_fg_color = @saved && @applied ? @green : @saved || @applied ? @yellow : @red
				2.upto(alloc.width - 3) do |n|
					w.draw_rectangle(led.style.fg_gc(led.state), true, n, 2, 2, alloc.height - 3) if 0 == n % 3
				end
				led.style.fg_gc(led.state).foreground = pc
			end
		end
		
	end
	
	#
	def changed
		@applied = @saved = false
		@led.queue_draw
	end
	
	#
	def applied
		puts "ajustando 'applied' em #{@label.text}" if $DEBUG
		@applied = true
		@led.queue_draw
	end
	
	#
	def saved
		puts "ajustando 'saved' em #{@label.text}" if $DEBUG
		@saved = true
		@led.queue_draw
	end
	
end

#
# label.rb - eof
