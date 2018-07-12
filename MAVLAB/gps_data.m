function [current_lat,current_lon,current_alt] = gps_data(address,port)

%Script for receiving GPS packets and decoding of messages
clear current_lat;
%Setup the TCP connection
tclient = tcpclient(address,port);

%Create a MAVLinkParser object to handle parsing of messages
parser = MAVLinkParser();

%Read packets until GPS data arrives
tic();
 while ~exist('current_lat','var') 
    
    %If bytes have been received over the TCP connection
    if tclient.BytesAvailable > 0
        
        %Read the first received byte of information
        byte = read(tclient,1,'uint8');
        %Parse the current byte of information
        packet = parser.parseChar(byte);
        
        %Check whether the parser returned a packet
        if ~isempty(packet)
            
            %Switch case runs different code depending on the msgid within the packet
            switch(packet.msgid)
                    
                %If the ID is 33 decode the packet as an position message
                case 33
                    message_position = msg_global_position_int(packet);
                    
                    current_lat = double(message_position.lat)/10^7;
                    current_lon = double(message_position.lon)/10^7;
                    current_alt = double(message_position.relative_alt)/1000;
                    
                    ID = packet.msgid;
%                 Otherwise the packet msgid is not supported by this script
%                 otherwise
%                     disp('No GPS data recieved');
% %                     ID = packet.msgid
                    
            end
        end
    end
end

%Close the TCP connection and clear the object
clear tclient;