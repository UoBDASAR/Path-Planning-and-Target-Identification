function[rawdata] = set_search_area()
fileID = fopen('search_area.poly','r');
fgets(fileID);  % Ignore first line
formatSpec = '%f %f';
sizeA = [2 Inf];
rawdata = fscanf(fileID, formatSpec, sizeA);
rawdata = rawdata';
end