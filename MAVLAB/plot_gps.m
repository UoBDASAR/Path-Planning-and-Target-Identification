clear;
clc();
tclient = tcpclient('127.0.0.1',14552);
parser = MAVLinkParser();
packet = [];
msg = [];
tic();

figure(1);
position = animatedline();
title('Position (WGS84)');
xlabel('Longitude');
ylabel('Latitude');

figure(2);
relativeAltitude = animatedline();
title('Relative Altitude');
xlabel('Time (s)');
ylabel('Altitude (m)');

while toc() <= 360

    if tclient.BytesAvailable > 0
        c = read(tclient,1,'uint8');
        packet = parser.parseChar(c);
        if isempty(packet) ~= 1
            if packet.msgid == 33
                time = toc();
                msg = packet.unpack();
                addpoints(position,(double(msg.lon)/(10^7)),(double(msg.lat)/(10^7)));
                addpoints(relativeAltitude,time,(double(msg.relative_alt)/1000));
                drawnow;
            end
        end      
    end

end

clear t;

