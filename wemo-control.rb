commands = [ON = 'ON',
            OFF = 'OFF',
            GETSTATE = 'GETSTATE',
            GETSIGNALSTRENGTH = 'GETSIGNALSTRENGTH',
            GETFRIENDLYNAME = 'GETFRIENDLYNAME']
ports = (49153..49155)

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

port = ports.find { |port| system("curl -s -m 3 #{ip}:#{port}") != '' }
unless port
  puts 'ERROR: could not determine port.'
  exit
end

puts "#{ip}:#{port} #{command}"

case command
when ON
  puts 'called ON'
  event = 'SetBinaryState'
  state_label = 'BinaryState'
  state = '1'
when OFF
  puts 'called OFF'
  event = 'SetBinaryState'
  state_label = 'BinaryState'
  state = '0'
when GETSTATE
  puts 'called GETSTATE'
  event = 'GetBinaryState'
  state_label = 'BinaryState'
  state = '1'
  puts extra_call = %Q(| sed 's/0/OFF/g' | sed 's/1/ON/g')
when GETSIGNALSTRENGTH
  puts 'called GETSIGNALSTRENGTH'
  event = 'GetSignalStrength'
  state_label = 'GetSignalStrength'
  state = '0'
when GETFRIENDLYNAME
  puts 'called GETFRIENDLYNAME'
end

puts call = %Q(curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset=\"utf-8\"' -H 'SOAPACTION: \"urn:Belkin:service:basicevent:1##{event}\"' --data '<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:#{event} xmlns:u=\"urn:Belkin:service:basicevent:1\"><#{state_label}>#{state}</#{state_label}></u:#{event}></s:Body></s:Envelope>' -s http://#{ip}:#{port}/upnp/control/basicevent1)
IO.popen(call) do |output|
  puts output.read
end


# IP=$1
# COMMAND=$2


#     PORT=0

#     for PTEST in 49152 49153 49154 49155
#     do
#             PORTTEST=$(curl -s -m 3 $IP:$PTEST | grep "404")

#             if [ "$PORTTEST" != "" ]
#                then
#                PORT=$PTEST
#                break
#             fi
#     done

#     if [ $PORT = 0 ]
#              then
#        echo "Cannot find a port"
#        exit
#     fi


#     if [ "$1" = "" ]
#        then
#           echo "Usage: ./wemo_control IP_ADDRESS ON|OFF"
#     else
#        echo "Port = "$PORT


#        if [ "$2" = "ON" ]

#           then

#              curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
#     grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1

#        elif [ "$2" = "OFF" ]

#           then

#              curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>0</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
#     grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1

#    elif [ "$2" = "GETSTATE" ]

#       then

#          curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:GetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
# grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1 | sed 's/0/OFF/g' | sed 's/1/ON/g'


#        else

#           echo "COMMAND NOT RECOGNIZED"
#           echo ""
#           echo "Usage: ./wemo_control IP_ADDRESS ON|OFF|GETSTATE"
#           echo ""

#        fi

#     fi
# fi