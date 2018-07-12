function [] =  disarming (address,port)

% Data used by this script to pack the disarming message
param1	= 0;% 1 for arm, 0 for disarm
param2	= 0;% Empty
param3	= 0;% Empty
param4	= 0;% Empty
param5	= 0;% Empty
param6	= 0;% Empty
param7	= 0;% Empty
command = 400;	% Command ID, as defined by MAV_CMD enum.	|	(uint16)
target_system = 1;% System which should execute the command	|	(uint8)
target_component = 0;% Component which should execute the command, 0 for all components	|	(uint8)
confirmation = 0; % 0: First transmission of this command. 1-255: Confirmation transmissions (e.g. for kill command)	|	(uint8)

%Setup the TCP connection
tclient = tcpclient(address,port);

%Create a new MAVLink command message (ID = 76) with initial data for the fields
message = msg_command_long(param1,param2,param3,param4,param5,param6,param7,command,target_system,target_component,confirmation);

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