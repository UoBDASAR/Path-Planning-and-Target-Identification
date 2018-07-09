function[] = write_waypoints(Dronexcurrent, Droneycurrent, Dronez, file_path)

% Transpose arrays
Dronexcurrent = Dronexcurrent';
Droneycurrent = Droneycurrent';
Dronez = Dronez';

% Set up matrix
[xsize1,~] = size(Dronexcurrent);
waypoints = [];

% File Path

% Create file and add header
fileID = fopen(file_path,'w');
fprintf(fileID,'%s \n','QGC WPL 110');
fclose(fileID);

% Add correct information to matrix
for ii = 1:xsize1
    
    %INDEX
    waypoints(ii,1) = ii-1;
    
    %CURRENT WP
    if ii == 1
        waypoints(ii,2) = 1;
    else
        waypoints(ii,2) = 0;    
    end
    
    %COORD FRAME
    waypoints(ii,3) = 3;
    
    %COMMAND
    waypoints(ii,4) = 16;
    
    %PARAM1
    waypoints(ii,5) = 0;
    
    %PARAM2
    waypoints(ii,6) = 0;
    
    %PARAM3
    waypoints(ii,7) = 0;
    
    %PARAM4
    waypoints(ii,8) = 0;
    
    %PARAM5/Y/LATITUDE
    waypoints(ii,9) = Droneycurrent(ii);
    
    %PARAM6/X/LONGITUDE
    waypoints(ii,10) = Dronexcurrent(ii);
    
    %PARAM7/Z/ALTITUDE
    waypoints(ii,11) = Dronez(ii);
    
    %AUTOCONTINUE
    waypoints(ii,12) = 1;
    
end

% write matrix to file
dlmwrite(file_path,waypoints,'delimiter','\t','precision',9,'-append')
end