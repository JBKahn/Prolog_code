flight(From, Airline, To, Price, Dur) :-
	fl(Airline, From, To, Price, Dur).
flight(From, Airline, To, Price, Dur) :-
	fl(Airline, To, From, Price, Dur).

% Tokyo - Beijing
fl(shenzen,tokyo,beijing,200,120).
fl(airchina,tokyo,beijing,250,100).

% Moscow - Istanbul
fl(turkishairlines,moscow,istanbul,300,180).
fl(lufthansa,moscow,istanbul,320,160).

% Istanbul - Tehran
fl(turkishairlines,istanbul,tehran,100,60).
fl(iranair,istanbul,tehran,60,65).

% Tehran - Beirut
fl(iranair,tehran,beirut,120,45).
fl(turkishairlines,tehran,beirut,130,40).

% Beirut - Istanbul
fl(turkishairlines,beirut,istanbul,200,70).

% Istanbul - Tokyo
fl(turkishairlines,istanbul,tokyo,530,360).

% Moscow - Tokyo
fl(japanairlines,moscow,tokyo,500,350).

% Istanbul - Beijing
fl(turkishairlines,istanbul,beijing,450,350).
fl(shenzhen,istanbul,beijing,400,360).
fl(airchina,istanbul,beijing,430,355).

% Munich - Moscow
fl(lufthansa,munich,moscow,220,130).

% Munich - Istanbul
fl(lufthansa,munich,istanbul,210,180).
fl(turkishairlines,munich,istanbul,220,165).

% Munich - Rome
fl(lufthansa,munich,rome,125,60).
fl(alitalia,munich,rome,100,80).

% Rome - Istanbul
fl(alitalia,rome,istanbul,130,160).
fl(turkishairlines,rome,istanbul,180,150).

% Rome - Moscow
fl(alitalia,rome,moscow,140,180).

% Monaco - Munich
fl(lufthansa,monaco,munich,80,45).

% Monaco - Rome
fl(alitalia,monaco,rome,70,40).

% Monaco - Nice
fl(airfrance,monaco,nice,80,50).

% Nice - Rome
fl(airfrance,nice,rome,120,100).
fl(alitalia,nice,rome,100,120).

% Nice - Munich
fl(airfrance,nice,munich,130,100).
fl(lufthansa,nice,munich,120,110).

% Capetown - Istanbul
fl(turkishairlines,capetown,istanbul,600,500).
fl(lufthansa,capetown,istanbul,620,480).
fl(airfrance,capetown,istanbul,660,440).

% Airport information
airport(tokyo,75,80).
airport(beijing,50,90).
airport(tehran,55,35).
airport(beirut,60,30).
airport(istanbul,55,60).
airport(moscow,50,65).
airport(munich,60,30).
airport(rome,60,35).
airport(nice,60,30).
airport(monaco,70,25).
airport(capetown,45,35).
airport(antarctica,20,100).
