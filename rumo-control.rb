commands = [ON = 'ON',
            OFF = 'OFF',
            GETSTATE = 'GETSTATE',
            GETSIGNALSTRENGTH = 'GETSIGNALSTRENGTH',
            GETFRIENDLYNAME = 'GETFRIENDLYNAME']
ports = (49152..49155)

ip = ARGV[0]
command = ARGV[1]
unless ip && command
  puts 'ERROR: missing options.'
  puts
  puts 'Usage: ruby wemo-control.rb IP_ADDRESS COMMAND'
  puts 'COMMANDS: ON|OFF|GETSTATE|GETSIGNALSTRENGTH|GETFRIENDLYNAME'
  exit
end

unless commands.include? command
  puts 'ERROR: invalid command.'
  puts
  puts 'Usage: ruby wemo-control.rb IP_ADDRESS COMMAND'
  puts 'COMMANDS: ON|OFF|GETSTATE|GETSIGNALSTRENGTH|GETFRIENDLYNAME'
  exit
end

port = ports.find { |port| system("curl -s -m 3 #{ip}:#{port}") }
unless port
  puts 'ERROR: could not determine port.'
  exit
end

case command
when ON
  event = 'SetBinaryState'
  state_label = 'BinaryState'
  state = '1'
when OFF
  event = 'SetBinaryState'
  state_label = 'BinaryState'
  state = '0'
when GETSTATE
  event = 'GetBinaryState'
  state_label = 'BinaryState'
  state = '1'
  puts extra_call = %Q(| sed 's/0/OFF/g' | sed 's/1/ON/g')
when GETSIGNALSTRENGTH
  event = 'GetSignalStrength'
  state_label = 'GetSignalStrength'
  state = '0'
when GETFRIENDLYNAME
  raise NotImplementedError, 'GETFRIENDLYNAME has not yet been implemented.'
end

call = %Q(curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset=\"utf-8\"' -H 'SOAPACTION: \"urn:Belkin:service:basicevent:1##{event}\"' --data '<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:#{event} xmlns:u=\"urn:Belkin:service:basicevent:1\"><#{state_label}>#{state}</#{state_label}></u:#{event}></s:Body></s:Envelope>' -s http://#{ip}:#{port}/upnp/control/basicevent1)
IO.popen(call) do |output|
  puts "\n\n" + output.read
end
