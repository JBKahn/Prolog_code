/** noAirlines defines the number of airlines in a given flightpath.
Parameters: The first parameter is a valid flight path and the second
parameter is a natural number.
noAirlines(+Path,?N)*/
noAirlines([],0).
/** No flights have 0 airlines.*/
noAirlines([[_, Airline,_] |Xs],Total) :- 
	not(member([_, Airline,_],Xs)), 
	noAirlines(Xs,Total1), 
	Total is 1 + Total1.
/** If an airline is distinct from those in the rest of the path,
	then it's part of the airline count.*/
noAirlines([[_, Airline,_] |Xs],Total) :- 
	member([_, Airline,_],Xs), 
	noAirlines(Xs,Total1), 
	Total is Total1.
/** If an airline is not distinct from those in the rest of the path, then
it's not part of the airline count.*/


/** lastitem defines the last item of a list.
Parameters: The first parameter is a list and the second parameter is the
last element of the list.*/
lastitem([Last], Last).
lastitem([_ | Rest], Last) :- lastitem(Rest, Last).
/** The last item in the element of the list such that there is only one
element after repeatedly removing the head.*/


/** newCost defines the total cost of a flight path after adding a new leg.
Parameters: The first parmeter is the old cost, the second parmeter is the
old airline, the third parmeter is the flight leg to be added and the fourth
paremeter is the new cost.*/
newCost(Cost, OldAirline,[From,Airline,To],NewCost) :- 
	flight(From,Airline,To,AirCost,_), 
	OldAirline = Airline, 
	NewCost is Cost + AirCost.
/** The new cost is the cost of the original flight and the new flight (as
well as the airport tax) if applicable.*/
newCost(Cost, OldAirline,[From,Airline,To],NewCost) :- 
	flight(From,Airline,To,AirCost,_), 
	not(OldAirline = Airline), 
	airport(To, PortCost, _), 
	NewCost is Cost + AirCost + PortCost.
/** The case where airport tax is applicable (change of airlines).*/

/** newWait defines the total amount of time a flightpath takes after
adding a new leg.
paremeters: The first paremeter is the old amount of time, the second paremeter
is the new leg and the third paremeter is the new total amount of time.
newWait(Delay,[From,Airline,To],NewDelay) :- 
	flight(From,Airline,To,_,Duration), 
	airport(From, _, PortTime), 
	NewDelay is Delay + Duration + PortTime.
/** The new delay is the delay of the original flight and the duration of
the new flight (as well as the airport minimum security). */

/** newRoute defines a new flightpath after adding a leg.
Paremeters: the first parmeter is the last leg of the original flight path, the
second paremeter is the destination of the new leg, the third paremeter is the
airline and the fourth paremeter is the new flightpath.*/
newRoute([_,_,From],To,Airline,NewRoute) :- NewRoute = [From,Airline,To].
/** The new route is the route of the original flight and the new flight
appended to it. */

/** addLeg defines thew new cost and time associated with adding a flight leg
to a given flight path with its own cost and time.
Paremeters: The first paramter is a valid flight route. The second parameter is
the destination of the new leg. The third parameter is the airline of the new leg.
The fourth paremeter is the new flight route.
addLeg(+Route,+To,+Airline,-NewRoute)*/
addLeg([Cost,Wait,_,FlightPath],To,Airline,[NewCost,NewWait,NewNumAirlines,NewFlightPath]) :-
	lastitem(FlightPath,[_,LastAirline,From]),
	newCost(Cost,LastAirline,[From,Airline,To],NewCost),
	newWait(Wait,[From,Airline,To],NewWait),
	append(FlightPath,[[From,Airline,To]],NewFlightPath),
	noAirlines(NewFlightPath,NewNumAirlines).
/** The cost, delay, number of airlines and new flight path are equal defined.
The new cost is the cost of the original flight and the new flight (as
well as the airport tax) if applicable.
The new delay is the delay of the original flight and the duration of
the new flight (as well as the airport minimum security).
The new route is the route of the original flight and the new flight
appended to it.
The new number of airlines is calculated from the new flight path.*/