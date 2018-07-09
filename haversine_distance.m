function[lengthlon,lengthlat] = haversine_distance(maxlat,maxlon,minlat,minlon)

% Converting degrees to radians
maxlatrad = deg2rad(maxlat);
maxlonrad = deg2rad(maxlon);

minlatrad = deg2rad(minlat);
minlonrad = deg2rad(minlon);

% Radius of earth
r = 6.371008*10^6;

lengthlon =  2*r*asin(sqrt((sin((maxlatrad-maxlatrad)/2))^2+cos(maxlatrad)*cos(maxlatrad)*(sin((maxlonrad-minlonrad)/2))^2));

lengthlat =  2*r*asin(sqrt((sin((maxlatrad-minlatrad)/2))^2+cos(maxlatrad)*cos(minlatrad)*(sin((minlonrad-minlonrad)/2))^2));

end