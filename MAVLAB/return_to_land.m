function [] = return_to_land(address,port)

%Arguments:
% custom_mode(MAVLinkPacket): Alternative way to construct a message using a MAVLinkPacket
custom_mode = 6;%: The new autopilot-specific mode. This field can be ignored by an autopilot.
target_system = 1; %: The system setting the mode
base_mode = 1;%: The new base mode

%Setup the TCP connection
tclient = tcpclient(address,port);

%Create a new MAVLink command message (ID = 76) with initial data for the fields
message = msg_set_mode(custom_mode,target_system,base_mode);

%MANUAL TRANSMISSION USING INDIVIDUAL FUNCTIONS (BETTER ERROR CHECKING)

%Pack the message into a MAVLink packet
packet = message.pack();
%Check that the message packed correctly
if ~isempty(packet);
    
    %Encode the packet as a stream of bytes
    sendBuffer = packet.encode();
    %Transmit the byte stream over the TCP connection
    write(tclient,sendBuffer);
    
end
    
%SIMPLE TRANSMISSION USING THE SEND FUNCTION (EASIER BUT ASSUMES CORRECT DATA)

%Send the message
message.send();

%Close the TCP connection and clear the object
clear tclient;