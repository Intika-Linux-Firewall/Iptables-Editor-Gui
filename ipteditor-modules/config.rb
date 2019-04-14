#
# configuracao.rb

#
# Define a classe Configuracao,
# que pode ser personalizada e usada para salvar configurações do programa
# copyleft 2009, by angico

#
# Dependências externas
require 'yaml'

class Configuracao
	attr_accessor :statusJan, :dimOmis
	def initialize(arqCfg)
		if Kernel.test(?f, arqCfg)
			File.open(arqCfg) do |arq|
				y = YAML.load(arq)
				y.instance_variables.each {|v| instance_variable_set v, y.instance_variable_get(v) }
			end
		else
			@statusJan = nil
			@dimOmis = [600, 400]
		end
	end
	#
	def salva(arqCfg)
		File.open(arqCfg, 'w') {|arq| YAML.dump(self, arq) }
	end
end

#
# configuracao.rb - eof
