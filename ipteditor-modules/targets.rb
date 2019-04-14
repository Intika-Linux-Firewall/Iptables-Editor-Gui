#
# targets.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

module Targets
	TARGETS = {
		'ACCEPT' => [],
		'DROP' => [],
		'QUEUE' => [],
		'RETURN' => [],
		
		# target extensions
		
		'CLASSIFY' => ['set-class*'],
		'CLUSTERIP' => ['new', 'hashmode*', 'clustermac*', 'total-nodes*', 'local-node*', 'hash-init*'],
		'CONNMARK' => ['set-xmark*', 'and-mark*', 'or-mark*', 'xor-mark*', 'set-mark*', 'save-mark*', 'restore-mark*'],
		'CONNSECMARK' => ['save', 'restore'],
		'DNAT' => ['to-destination*', 'random'],
		'DSCP' => ['set-dscp*', 'set-dscp-class*'],
		'ECN' => ['ecn-tcp-remove'],
		'LOG' => ['log-level*', 'log-prefix*', 'log-tcp-sequence', 'log-tcp-options', 'log-ip-options', 'log-uid'],
		'MARK' => ['set-xmark*', 'set-mark*', 'and-mark*', 'or-mark*', 'xor-mark*'],
		'MASQUERADE' => ['to-ports*', 'random'],
		'MIRROR' => [],
		'NETMAP' => ['to*'],
		'NFLOG' => ['nflog-group*', 'nflog-prefix*', 'nflog-range*', 'nflog-threshold*'],
		'NFQUEUE' => ['queue-num*'],
		'NOTRACK' => [],
		'RATEEST' => ['rateest-name*', 'rateest-interval*', 'rateest-ewmalog*'],
		'REDIRECT' => ['to-ports*', 'random'],
		'REJECT' => [
			'reject-with*icmp-net-unreachable*icmp-host-unreachable*icmp-port-unreachable*icmp-proto-unreachable*icmp-net-prohibited*icmp-host-prohibited*icmp-admin-prohibited'
		],
		'SAME' => ['to*', 'nodst', 'random'],
		'SECMARK' => ['selctx*'],
		'SET' => ['add-set*', 'del-set*'],
		'SNAT' => ['to-source*', 'random'],
		'TCPMSS' => ['set-mss*', 'clamp-mss-to-pmtu'],
		'TCPOPTSTRIP' => ['strip-options*'],
		'TOS' => ['set-tos*Minimize-Delay*Maximize-Throughput*Maximize-Reliability*Minimize-Cost*Normal-Service', 'and-tos*', 'or-tos*', 'xor-tos*'],
		'TRACE' => [],
		'TTL' => ['ttl-set*', 'ttl-dec*', 'ttl-inc*'],
		'ULOG' => ['ulog-nlgroup*', 'ulog-prefix*', 'ulog-cprange*', 'ulog-qthreshold*']
	}
end

#
# targets.rb - eof
