function [] = waypoint2(drone_latitude, drone_longitude, drone_altitude, address, port)

param1 = 0;	%PARAM1, see MAV_CMD enum	|	(single)
param2 = 0;%PARAM2, see MAV_CMD enum	|	(single)
param3 = 0;%PARAM3, see MAV_CMD enum	|	(single)
param4 = 0;%PARAM4, see MAV_CMD enum	|	(single)
x = drone_latitude; %PARAM5 / local: x position, global: latitude	|	(single)
y = drone_longitude;%PARAM6 / y position: global: longitude	|	(single)
z = drone_altitude; %PARAM7 / z position: global: altitude (relative or absolute, depending on frame.	|	(single)
seq	= 0; % Sequence	|	(uint16)
command	 = 16; % The scheduled action for the waypoint, as defined by MAV_CMD enum	|	(uint16)
target_system = 255;%System ID	|	(uint8)
target_component = 1;	%Component ID	|	(uint8)
frame = 3;	%The coordinate system of the waypoint, as defined by MAV_FRAME enum	|	(uint8)
current	= 0;%false:0, true:1	|	(uint8)
autocontinue = 1;	%autocontinue to next wp	|	(uint8)
% mission_type = 0;

%Setup the TCP connection
tclient = tcpclient(address,port);

%Create a new MAVLink command message (ID = 76) with initial data for the fields
message = msg_mission_item(param1,param2,param3,param4,x,y,z,seq,command,target_system,target_component,frame,current,autocontinue);

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