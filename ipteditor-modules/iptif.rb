#
# iptif.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

class IPTInterface
	def read
		@cmd = 0
		run "/sbin/iptables-save"
	end
	#
	def apply(s)
		@cmd = 1
		@s = s
		run "/sbin/iptables-restore"
	end
	#
	def run(cmd, arg = '')
		read_in, write_in = IO.pipe
		read_out, write_out = IO.pipe
		
		if fork
			# processo pai
			# parent process
			
			# fechamos os fluxos desnecessários
			# close unnecessary streams
			write_in.close
			read_out.close
			
			s = []
			
			if @cmd == 0
				while lin = read_in.gets
					s << lin
				end
			else
				write_out.puts @s
			end
			
			read_in.close
			write_out.close
			Process.wait
			
			s.join("\n") if s.length

		else
			# processo filho
			# child process
			
			# fechamos o fluxo desnecessário
			# close unnecessary stream
			read_in.close
			write_out.close
			
			# redirecionamos saída padrão do processo filho
			# redirect standard output of child process
			STDOUT.reopen write_in
			STDIN.reopen read_out
			
			# executamos o comando desejado
			# execute desired command
			if arg.empty?
				exec cmd
			else
				exec cmd, arg
			end
			
			# provavelmente não chegaremos aqui, mas por via das dúvidas...
			# probably never reach here, nevertheless...
			write_in.close
			read_out.close
			exit 1
		end
	end
end

#
# iptif.rb - eof
