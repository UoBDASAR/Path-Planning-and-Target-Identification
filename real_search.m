close all
clear all

%%%%%%%%%%% THINGS TO CHANGE %%%%%%%%%%%

% file path for waypoints file
file_path = 'C:\Users\david\Documents\University\Internship\MATLAB\Path Planning\search_waypoints.txt';
% Path Width (m)
width = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get Coordinates of search area
[rawdata] = set_search_area;
% Coordinate order is fliped as MATLAB does polygons clockwise and mission planner does them anti clockwise
rawdata = flip(rawdata); 
lat = rawdata(:,1);
lon = rawdata(:,2);

% Find coordinates of rectangle that encompasses the search area
maxlat = max(lat);
maxlon = max(lon);

minlat = min(lat);
minlon = min(lon);

% Working out size of search area

[lengthlon,lengthlat] = haversine_distance(maxlat,maxlon,minlat,minlon);

% Show satellite map centering it around the search area
webmap('World Imagery');
centreLatitude = (maxlat + minlat)/2;
centreLongitude = (maxlon + minlon)/2;
zoomLevel = 18;
wmcenter(centreLatitude, centreLongitude, zoomLevel);

% Setup up array to plot the rectangle on the map
lat1=[minlat, maxlat, maxlat, minlat, minlat];
lon1=[minlon, minlon, maxlon, maxlon, minlon];

% Plotting polygon search area and rectangle on the map
wmpolygon(lat,lon,'EdgeColor','g','FaceColor','c','FaceAlpha',.5);
wmpolygon(lat1,lon1,'EdgeColor','r','FaceColor','m','FaceAlpha',.5);

% Path Width (m)
width = 10;
% Number of cells in lat and lon direction
numlat= ceil(lengthlat/width);
numlon= ceil(lengthlon/width);
% Define Cell Size based on search area size
x=linspace(minlon, maxlon, numlon);
y=linspace(minlat, maxlat, numlat);
% Produce Grid
[X,Y]=meshgrid(x,y);

% % Find grid points that lie within the polygon
% in = inpolygon(X,Y,lon,lat);
% % Convert logical to double
% check_in = double(in);
% % Set points inside the polygon to 0 and points outside to -11
% check_in(check_in==0)=-11;
% check_in(check_in==1)=0;

% Map Data for Z coordinates
% filename = 'GridData.xlsx';
% Grid = xlsread(filename,'A1:J10');
Grid = ones(numlat,numlon);

%Define Probability Distribution
C = ones(numlat,numlon);
% C = C+check_in;

C1=C;
% Surround array with boundary
C1 = padarray(C1,[1 1],-10,'both');

%Find max of Function
[max_C1 , max_idx]=max(C1(:)); 
[Y_idx , X_idx]=ind2sub(size(C1),max_idx);

%Find min of Function
[min_C1,min_idx]=min(C1(:)); 
% [Y_idx X_idx]=ind2sub(size(C),max_idx);

%Drone Location

%Maximum
Dronexstart=x(X_idx-1);
Droneystart=y(Y_idx-1);

Dronexcurrent(1)= Dronexstart;
Droneycurrent(1)= Droneystart;

Dronexidx=X_idx;
Droneyidx=Y_idx;

Dronez = Grid(Droneyidx-1,Dronexidx-1)+9;

minz= min(Dronez);

%Max number of steps
n=4000;

for i = 1:n
    % while max(C1)>0;
    % i=1;
    
    Dronexidx = Dronexidx;
    Droneyidx = Droneyidx;
    
    % Find Index of cells around current position
    Dronexidx_top = Dronexidx;
    Dronexidx_right = Dronexidx+1;
    Dronexidx_bottom = Dronexidx;
    Dronexidx_left = Dronexidx-1;
    
    Droneyidx_top = Droneyidx-1;
    Droneyidx_right = Droneyidx;
    Droneyidx_bottom = Droneyidx+1;
    Droneyidx_left = Droneyidx;
    
    % Evaluate the probability in those cells
    C1_top = C1(Droneyidx_top, Dronexidx_top);
    C1_right = C1(Droneyidx_right, Dronexidx_right);
    C1_bottom = C1(Droneyidx_bottom, Dronexidx_bottom);
    C1_left = C1(Droneyidx_left, Dronexidx_left);
    
    Cl_NE = C1(Droneyidx_top, Dronexidx_right);
    Cl_SE = C1(Droneyidx_bottom, Dronexidx_right);
    Cl_SW = C1(Droneyidx_bottom, Dronexidx_left);
    Cl_NW = C1(Droneyidx_top, Dronexidx_left);
    
    % Store the probability in an array
    C1_array = [];
    C1_array(1) = C1_top;
    C1_array(2) = C1_right;
    C1_array(3) = C1_bottom;
    C1_array(4) = C1_left;
    Cl_array(5) = Cl_NE;
    Cl_array(6) = Cl_SE;
    Cl_array(7) = Cl_SW;
    Cl_array(8) = Cl_NW;
    
    % Find maximum value in surrounding cells
    [Largest , Position] = max(C1_array);
    C1(Droneyidx,Dronexidx) = -5;
    
    %Find max of remaining cells
    [max_remain,max_idxremain]=max(C1(:));
    [Y_idxremain , X_idxremain]=ind2sub(size(C1),max_idxremain);
    
    % Choosing where to go next
    if all(C1_array <0)
        %Dronexidx=X_idxremain;
        %Droneyidx=Y_idxremain;
        
        %Find nearest remaining cell
        remaining = find(C1 > 0);
        [Y_idxrem , X_idxrem]=ind2sub(size(C1),remaining);
        [xsize_remain, ysize_remain]= size(X_idxrem);
        distance = [];
        
        %find distance
        for count = 1:xsize_remain
            distance(count) = sqrt((Dronexidx-X_idxrem(count))^2+(Droneyidx-Y_idxrem(count))^2);
        end
        
        [nearest_cell , cell_location] = min(distance);
        
        Dronexidx = X_idxrem(cell_location);
        Droneyidx = Y_idxrem(cell_location);
        
    elseif Position == 1
        Dronexidx = Dronexidx_top;
        Droneyidx = Droneyidx_top;
    elseif Position == 2
        Dronexidx = Dronexidx_right;
        Droneyidx = Droneyidx_right;
    elseif Position == 3
        Dronexidx = Dronexidx_bottom;
        Droneyidx = Droneyidx_bottom;
    elseif Position == 4
        Dronexidx = Dronexidx_left;
        Droneyidx = Droneyidx_left;
    elseif Position == 5
        Dronexidx = Dronexidx_right;
        Droneyidx = Droneyidx_top;
    elseif Position == 6
        Dronexidx = Dronexidx_right;
        Droneyidx = Droneyidx_bottom;
    elseif Position == 7
        Dronexidx = Dronexidx_left;
        Droneyidx = Droneyidx_bottom;
    elseif Position == 8
        Dronexidx = Dronexidx_left;
        Droneyidx = Droneyidx_top;
    end
    
    if all(C1<0)
        
        break
    end
    
    Dronexnew=x(Dronexidx-1);
    Droneynew=y(Droneyidx-1);
    
    Dronexcurrent(i+1)= Dronexnew;
    Droneycurrent(i+1)= Droneynew;
    
    Dronez(i+1)= Grid(Droneyidx-1,Dronexidx-1) + 9;
    
    
    %    if i == 1000
    %         C1(C1>0)=0;
    %         C1=C2+C1;
    %         C3=C1;
    %    end
    %    i=i+1;
end




% %plot distribution
figure(1)
% % surf(X,Y,C,'EdgeColor','none');
view(0,90);
% %shading('flat');
hold on 
[xsize,ysize] = size(Dronexcurrent);
% Plot drone path
for j=1:ysize
    
    % if j<=1000
    plot3(Dronexcurrent(1:j),Droneycurrent(1:j),Dronez(1:j),'r','LineWidth',2);
    % else
    %
    %     plot3(Dronexcurrent(1001:j),Droneycurrent(1001:j),Dronez(1001:j),'k','LineWidth',2);
    % end
    
    
    pause(0.01)
    
end

% Plot search areas on graph 
plot(lon,lat);
plot(lon1,lat1);

% Plot search path on map
wmline(Droneycurrent,Dronexcurrent);

% Plot start and finish markers on map
wmmarker(Droneycurrent(1),Dronexcurrent(1),'FeatureName', 'Start');

wmmarker(Droneycurrent(ysize),Dronexcurrent(ysize),'FeatureName', 'End');

write_waypoints(Dronexcurrent, Droneycurrent, Dronez, file_path)