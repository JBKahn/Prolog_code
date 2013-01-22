% true if there is a city you can visit from you current city that you have not been to.
% The first parameter is the origin city and the second parameter is the list of cities you have been to.
% canGoPlaces(+Origin,+Cities)
canGoPlaces(Origin,[]) :- 
	flight(Origin,_,_,_,_), !.
	% There are places you can fly to if there is a flight somewhere and you haven't been anywhere yet.
canGoPlaces(Origin,Cities) :- 
	flight(Origin,_,Destination,_,_), 
	not(member(Destination,Cities)),!.
	% There are places you can fly to if there is a single flight to somewhere that you haven't been.

% Defines the cost of a given non-redundant flight path.
% The first parameter is a non-redundant path and the second paramamer is an integer price.
% computePrice(+Path,?Price)
computePrice([],0).
computePrice([[City1, Airport1,City2]|Xs],Price):- 
	computePriceHelper([[City1, Airport1,City2]|Xs],Price2),
	airport(City1,E,_),
	Price is Price2 + E.
	% The price is added from the origin airport to allow for the use of a general set of rules for path price calculation.

% Defines the cost of a given non-redundant path, minus the cost of the original airport.
% The first parameter is a non-redundant path and the second paramamer is an integer price.
% computePrice(?Path,?Price)
computePriceHelper([[A, B,C]],Price):- 
	flight(A,B,C,D,_),
	Price = D.
	% The price of a single flight is the cost of the flight itself.
computePriceHelper([[City1, Airport1,City2]|[[City2, Airport2,City3] |Xs]],Price):- 
	flight(City1,Airport1,City2,D,_),
	(
		(not(Airport1 = Airport2), airport(City2, E, _))
		;
		(Airport1=Airport1,E=0 )
	),
	% A change in airlines requires that the cost of the next airport tax be added where the change occurs.
	computePriceHelper([[City2, Airport2,City3] |Xs], SubPrice),!,
	Price is D + E + SubPrice.

% Defines the duration of a given non-redundant flight path.
% The first parameter is a non-redundant path and the second paramamer is an integer duration.
% computeDuration(+Path,?Duration)
computeDuration([],0).
computeDuration([[A, B,C]],Duration):- 
	flight(A,B,C,_,D), 
	airport(A,_,E),
	Duration is D + E.
	% The duration of a single flight is the wait at the initial airport and the duration of the flight.
computeDuration([[City1, Airport1,City2]|[[City2, Airport2,City3] |Xs]], Duration):- 
	flight(City1,Airport1,City2,_,D),
	airport(City1,_,E), 
	computeDuration([[City2, Airport2,City3] |Xs], SubDuration),
	Duration is D + E + SubDuration.
	% The duration of a flight is the wait at the initial airport and the duration of the initiatl flight,
	% as well as the duration of the rest of the flight path.

% Defines the number of airlines in a given non-redundant flight path.
% The first parameter is a non-redundant path and the second paramamer is an integer number of airlines.
% computeNoAirlines(+Path,?NoAirlines)
computeNoAirlines([],0).
computeNoAirlines([[C, Airline,D]],Total) :- 
	flight(C,Airline,D,_,_),
	Total is 1.
	% A single flight has 1 airline.
computeNoAirlines([[_, Airline,City2]|[[City2, Airport2,City3] |Xs]],Total) :- 
	computeNoAirlines([[City2, Airport2,City3] |Xs],Total1),!,
	(
		(not(member([_, Airline,_],[[City2, Airport2,City3] |Xs])), Total is 1 + Total1) 
		; 
		(member([_, Airline,_],[[City2, Airport2,City3] |Xs]), Total is Total1)
	),!.
	% A single flight in the path, from left to right, only counts an airline if there is no other reference
	% to that airline to it's right. This ensures each airline is only counted once.

% Defines a well formed non-redundant flight path, given an origin, destination and list of forbidden cities.
% The first parameter is the origin airport.
% The second parameter is the destination airport.
% The third parameter is the well formed non-redundant flight path.
% The fourth parameter is a lsit of cities which you may not travel to.
% wellFormedPath(+Origin,+Destination,?Path,+ListOfForbiddenCities)
wellFormedPath(_,_,[],_).
wellFormedPath(Origin,Destination,[[Origin, B,Destination]],_):- 
	flight(Origin,B,Destination,_,_).
wellFormedPath(Origin,Destination,[[Origin, Airport1,City2]|[[City2, Airport2,City3] |Xs]],Cities):- 
	airport(Destination,_,_),
	flight(Origin,Airport1,City2,_,_),
	not(City2 = Destination),
	% A path from one place to itself doesn't count.
	not(member(City2,Cities)),
	% We are not trying to travel to a city we are forbidden to go to.
	append([City2,Origin],Cities,Cities2),
	% Add the cities we have been to, to the list of the forbidden cities.
	canGoPlaces(City2,Cities2),
	% Ensures that there exists a place we can go from here, before trying to find one.
	wellFormedPath(City2,Destination,[[City2,Airport2,City3]|Xs],Cities2).

% Defines a well formed non-redundant flight path.
% The first parameter is the origin airport.
% The second parameter is the destination airport.
% The third parameter is the well formed non-redundant flight path.
% findPath(?Origin,?Destination,?Path)
findPath(Origin,Origin,[]).
findPath(Origin,Destination,Path) :- 
	airport(Origin,_,_),
	airport(Destination,_,_),
	not(Origin = Destination),
	% A path from one place to itself doesn't count.
	wellFormedPath(Origin,Destination,Path,[]),
	% The list of forbidden cities is set to [], meaning we can visit any city.
	not(Path = []).
	% The path must not be null.

% Defines a well formed non-redundant flight path.
% The first parameter is the origin airport.
% The second parameter is the destination airport.
% The third parameter is the well formed non-redundant flight route.
% The first parameter of a route is the price of the route path.
% The second parameter of a route is the duration of the route path.
% The third parameter of a route is the number of airlines in the route path.
% The fourth parameter of a route is the path of the route.
% trip(?Origin,?Destination,?Route)
% Route is [?Price, ?Dur, ?N, ?Path]
trip(Origin,Destination,[Price,Dur,N,Path]) :- 
    findPath(Origin,Destination,Path),
    not(Path = []),
    computePrice(Path,Price),
    computeDuration(Path,Dur),
    computeNoAirlines(Path, N).