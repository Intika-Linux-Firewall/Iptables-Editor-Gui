#
# criteria.rb

#
# Este arquivo é parte do programa IPTEditor
# e é distribuído de acordo com a Licença Geral Pública do GNU - GPL
# This file is part of the IPTEditor program
# and is distributed under the terms of GNU General Public License - GPL
#
# Copyleft 2009, by angico.

class IPTModule
	attr_reader :name, :options
	def initialize
	end
end

class IPTModuleOptions
	def initialize
	end
end

class IPTModuleOption
	attr_reader :negatable, :name
	def initialize
	end
end

module Criteria
	CRITERIA = {
		'addrtype' => [
			'!src-type*UNSPEC*UNICAST*LOCAL*BROADCAST*ANYCAST*MULTICAST*BLACKHOLE*UNREACHABLE*PROHIBIT*THROW*NAT*XRESOLVE',
			'!dst-type*UNSPEC*UNICAST*LOCAL*BROADCAST*ANYCAST*MULTICAST*BLACKHOLE*UNREACHABLE*PROHIBIT*THROW*NAT*XRESOLVE',
			'limit-iface-in', 'limit-iface-out'
		],
		'ah' => ['!ah-spi*'],
		'comment' => ['comment*'],
		'connbytes' => ['!connbytes*', 'connbytes-dir*original*reply*both', 'connbytes-mode*packets*bytes*avgpkt'],
		'connlimit' => ['!connlimit-above*', 'connlimit-mask*'],
		'connmark' => ['!mark*'],
		'conntrack' => [
			'!ctstate*INVALID*NEW*ESTABLISHED*RELATED*SNAT*DNAT', '!ctproto*', '!ctorigsrc*', '!ctorigdst*', '!ctreplsrc*',
			'!ctrepldst*', '!ctorigsrcport*', '!ctorigdstport*', '!ctreplsrcport*', '!ctrepldstport*',
			'!ctstatus*NONE*EXPECTED*SEEN_REPLY*ASSURED*CONFIRMED', '!ctexpire*', 'ctdir*ORIGINAL*REPLY'
		],
		'dccp' => ['!sport*', '!dport*', '!dccp-types*', '!dccp-option*'],
		'dscp' => ['!dscp*', '!dscp-class*'],
		'ecn' => ['!ecn-tcp-cwr', '!ecn-tcp-ece', '!ecn-ip-ecp*'],
		'esp' => ['!espspi*'],
		'hashlimit' => [
			'hashlimit-upto*', 'hashlimit-above*', 'hashlimit-burst*', 'hashlimit-mode*srcip*srcport*dstip*dstport', 'hashlimit-srcmask*',
			'hashlimit-dstmask*', 'hashlimit-name*', 'hashlimit-htable-size*', 'hashlimit-htable-max*',
			'hashlimit-htable-expire*', 'hashlimit-htable-gcinterval*'
		],
		'helper' => ['!helper*'],
		'icmp' => ['!icmp-type*'],
		'iprange' => ['!src-range*', '!dst-range*'],
		'length' => ['!length*'],
		'limit' => ['!limit*', 'limit-burst*'],
		'mac' => ['!mac-source*'],
		'mark' => ['!mark*'],
		'multiport' => ['!sport*', '!dport*', '!ports*'],
		'owner' => ['!uid-owner*', '!gid-owner*', '!socket-exists'],
		'physdev' => ['!physdev-in*', '!physdev-out*', '!physdev-is-in', '!physdev-is-out', '!physdev-is-bridged'],
		'pkttype' => ['!pkt-type*unicast*broadcast*multicast'],
		'policy' => [
			'dir*in*out', 'pol*none*ipsec', 'strict', '!reqid*', '!spi*', '!proto*ah*esp*ipcomp', '!mode*tunnel*transport',
			'!tunnel-src*', '!tunnel-dst*', 'next'],
		'quota' => ['quota*'],
		'realm' => ['!realm*'],
		'recent' => ['name*', '!set', '!rcheck', '!update', '!remove', '!seconds*', '!hitcount*', 'rsource', 'rdest'],
		'sctp' => ['!sport*', '!dport*', '!chunk-types*all*any*only'],
		'set' => ['!set*'],
		'state' => ['!state*INVALID*ESTABLISHED*NEW*RELATED*NEW,RELATED*NEW,RELATED,ESTABLISHED'],
		'statistic' => ['mode*random*nth', 'probability*', 'every*', 'packet*'],
		'string' => ['algo*bm*kmp', 'from*', 'to*', '!string*', '!hex-string*'],
		'tcp' => ['!sport*', '!dport*', '!tcp-flags*', '!syn', '!tcp-option*'],
		'tcpmss' => ['!mss*'],
		'time' => ['datestart*', 'datestop*', 'timestart*', 'timestop*', '!monthdays*', '!weekdays*', 'utc', 'localtz'],
		'tos' => ['!tos*'],
		'ttl' => ['ttl-eq*', 'ttl-gt*', 'ttl-lt*'],
		'u32' => ['!u32*'],
		'udp' => ['!sport*', '!dport*'],
		'unclean' => []
	}
end

#
# criteria.rb - eof
