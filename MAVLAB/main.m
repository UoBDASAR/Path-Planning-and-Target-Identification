close all
clear all

% Communication Parameters
address = '127.0.0.1';
port = 14552;

% GPS Tolerances
tolerance_lat_lon = 0.00001;
tolerance_alt = 0.5;

%Desired Drone Coordinates in WGS84 
desired_drone_latitude = 51.4666449;  
desired_drone_longitude = -2.6233489; 
desired_drone_altitude = 5; 

%Arming the Drone
arming(address,port)

pause(4);

% Setting Drone to Guided Mode
guided_mode(address,port)

pause(2);

% Used to start mission without RC controller to increase throttle 
take_off(address,port)

pause(5);

% % Get current position from GPS data
% [live_drone_latitude,live_drone_longitude,live_drone_altitude] = gps_data(address,port); 
% 
% Obtain difference between commanded and current location
% diff = abs([desired_drone_latitude;desired_drone_longitude;desired_drone_altitude]-...
%     [live_drone_latitude;live_drone_longitude;live_drone_altitude]);
 
% Send desired location to drone using loiter function
% while 1
waypoint2(desired_drone_latitude,desired_drone_longitude,desired_drone_altitude,address,port);
% pause(0.01);
% end
pause(20);


% 
% % Pausing script whilst drone travels to target
% while max(diff(1:2))> tolerance_lat_lon && diff(3)> tolerance_alt
%     % Get current position from GPS data
%     [live_drone_latitude,live_drone_longitude,live_drone_altitude] = gps_data(address,port);
%     
%     % Obtain difference between commanded and current location
%     diff = abs([desired_drone_latitude;desired_drone_longitude;desired_drone_altitude]-...
%         [live_drone_latitude;live_drone_longitude;live_drone_altitude]);
%     
%     pause(0.1)
% end

% Returning to land at end of mission
return_to_land(address,port)