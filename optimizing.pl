% optimizing.pl requires trip.pl.
:- ['trip.pl']. 


% Satisfied if the Criterion, price or duration, is below C_limit.
% The first parameter is the criterion, 'price' or 'duration'.
% The second parameter is the limit of the criterion.
% The third parameter is the price.
% The fourth parameter is the duration.
% belowCriterion(+Criterion,+C_Limit,+Price,+Dur)
belowCriterion(Criterion,C_Limit,Price, Dur) :- 
	(
		(Criterion = price, Price < C_Limit) 
		; 
		(Criterion = duration, Dur < C_Limit)
	).

% Defines the new C_limit given a Criterion, C_limit, Price and Duration.
% The first parameter is the criterion, 'price' or 'duration'.
% The second parameter is the limit of the criterion.
% The third parameter is the price.
% The fourth parameter is the duration.
% The fifth parameter is the new limit of the criterion.
% belowCriterion(+Criterion,+C_Limit,+Price,+Dur,-NewCrit)
reduceCriterion(Criterion,C_Limit,Price, Dur, NewCrit) :- 
	(
		(Criterion = price, NewCrit is C_Limit - Price)
		;
		(Criterion = duration, NewCrit is C_Limit - Dur)
	).

% Defines a well formed non-redundant flight route, given an origin, destination, lsit of forbidden cities, list of visited airlines, 
% criterion and criterion limit.
% The first parameter is the Origin of the route.
% The second parameter is the Destination of the route.
% The third parameter is the Path of the route.
% The fourth parameter is the list of cities which you may not travel to.
% The fifth parameter is the price of the route.
% The sixth parameter is the duration of the route.
% The seventh parameter is the number of airlines in the route path.
% The eighth parameter is the list of airlines we have already visted.
% The ninth parameter is the Criterion, either 'price' of 'duration'.
% The tenth parameter is the limit of the criterion.
% belowCriterion(+Origin, +Destination, ?Path, +Cities, ?Price, ?Duration, ?NoAirLines, +AirlinesVisited, +Criterion, +C_Limit)
wellFormedRoute(_,_,[],_,_,_,_,_,_,_).
wellFormedRoute(Origin,Destination,[[Origin, B,Destination]],_,Price,Duration,NoAirlines,ListAirlines,Criterion,C_Limit):- 
	flight(Origin,B,Destination,Price,AirplaceDur),
	% Price is the price of the flight.
	airport(Origin,_,AirportDur),
	Duration is AirportDur + AirplaceDur,
	% Duration is the wait at the airport and the duration of the flight.
	belowCriterion(Criterion,C_Limit,Price, Duration),
	% Check the route is currently below the criterion, before continuing down the current path.
	(
		(member(B, ListAirlines),NoAirlines = 0 ) 
		; 
		(not(member(B, ListAirlines)), NoAirlines = 1)
	).
wellFormedRoute(Origin,Destination,[[Origin, Airport1,City2]|[[City2, Airport2,City3] |Xs]],Cities,Price,Duration,NoAirlines,ListAirlines,Criterion,C_Limit):- 
	airport(Destination,_,_),
	flight(Origin,Airport1,City2,AirplanePrice, AirplaceDur),
	not(City2 = Destination),
	% We may not visit the distination mid path.
	not(member(City2,Cities)),
	% The city we are about to visit must be a city we are allowed to visit.
	(
		(not(Airport2=Airport1), airport(City2, CityPrice, CityDur)) 
		; 
		(Airport2=Airport1,airport(City2, _, CityDur), CityPrice = 0)
	),
	% The cost of stopping over mid flight is determined by the airline of the next part of the flight.
	append([City2,Origin],Cities,Cities2),
	% Add the visited cities to cities where we cannot go to.
	canGoPlaces(City2,Cities2),
	% It is verified that, on the given path, there is a city to go to without creating a redundant path.
	belowCriterion(Criterion,C_Limit,AirplanePrice + CityPrice, AirplaceDur + CityDur),
	% The path is checked if it is, thus far, below the criterion Criterion, stored in C_Limit.
	reduceCriterion(Criterion,C_Limit,AirplanePrice + CityPrice, AirplaceDur + CityDur, NewCrit),
	% The criterion is reduced once we know the path was within the specific criterion thus far.
	(
		(member(Airport1, ListAirlines),IsNewAirline = 0) 
		; 
		(not(member(Airport1, ListAirlines)), IsNewAirline = 1)
	),
	% The number of airlines is incrimented if the airline has not been encountered before, as per the list of airlines we have already visited.
	append([Airport1],ListAirlines,ListAirlines2),
	% The airport is added to the list of airports we have encountered so far.
	wellFormedRoute(City2,Destination,[[City2,Airport2,City3]|Xs],Cities2, Price2, Dur2, NoAirlines2, ListAirlines2,Criterion, NewCrit),
	NoAirlines is NoAirlines2 + IsNewAirline,
	Price is Price2 + AirplanePrice + CityPrice,
	% Price is the price of the flight, the price added due to potentially switching airlines and the prince of the rest of the path.
	Duration is AirplaceDur + CityDur + Dur2,!.
	% Duration is the wait at the airport and the duration of the flight and the duration of the rest of the path.

% Defines a well formed non-redundant flight route, below a given limit in the criterion of 'price' or 'duration'. 
% Precondition: Criterion is instantiated to either price or duration; C_Limit is instantiated to a number.
% The first parameter is the Origin of the route.
% The second parameter is the Destination of the route.
% The third parameter is the Criterion, either 'price' of 'duration'.
% The fourth parameter is the limit of the criterion.
% The fifth parameter is the flight route.
% belowCriterion(?Origin, ?Destination, +Criterion, +C_Limit, -Route)
findTrip(Origin,Destination,Criterion,C_Limit,Route) :-
	airport(Origin,AirportPrice,_),
	airport(Destination,_,_),
	not(Origin = Destination),
	wellFormedRoute(Origin,Destination,Path,[],Price2,Duration,NoAirlines,[],Criterion,C_Limit),
	not(Path = []),
	Price is Price2 + AirportPrice,
	Route = [Price, Duration, NoAirlines, Path],
	belowCriterion(Criterion,C_Limit,Price2 + AirportPrice, Duration).

% True if the second flight is better than the first with respect to the Criterion.
% The first parameter is the criterion, price or duration.
% The second parameter is the price of the first trip.
% The third parameter is the price of the second trip.
% The fourth parameter is the duration of the first trip.
% The fifth parameter is the duration of the second trip.
% isABetterTrip(+Criterion,+FirstPrice,+SecondPrice,+FirstDuration, +SecondDuration)
isABetterTrip(price, TripPrice, NewPrice, _, _) :- 
	NewPrice < TripPrice.
isABetterTrip(duration, _, _, TripDuration, NewDuration) :- 
	NewDuration < TripDuration.

% Defines the best flight from Origin to Destination, along route Route, with respect to the Criterion.
% Precondition: Criterion is instantiated to either price or duration.
% The first parameter is the Origin of the route.
% The second parameter is the Destination of the route.
% The third parameter is the Criterion, either 'price' of 'duration'.
% The fourth parameter is the flight route.
% bestTrip(?Origin, ?Destination, +Criterion, -Route)
bestTrip(Origin,Destination,Criterion,Route) :-
	airport(Origin,_,_),
	airport(Destination,_,_),
	not(Origin = Destination),
	bestTripHelper(Origin,Destination,Criterion,Route).
	% If the origin and desitnation were not given then it will find the best route for each combination by backtracking.

% Defines the best flight, from the given and Origin to Destination, with respect to the Criterion.
% The first parameter is the Origin of the route.
% The second parameter is the Destination of the route.
% The third parameter is the Criterion, either 'price' of 'duration'.
% The fourth parameter is the flight route.
% bestTripHelper(+Origin, +Destination, +Criterion, -Route)
bestTripHelper(Origin,Destination,Criterion,Route) :-
	trip(Origin,Destination,[Price,Dur,N,Path]),!,
	% Calculate the cost of the first trip for comparison purposes.
	% The cut forces it to find the minimum only once by preveneting backtracking of the initial starting criterion limit.
	findBestTrip(Origin,Destination,Criterion,[Price,Dur,N,Path],Min),
	Route = Min.

% Defines if the given route is the best route with respect to the given criteron.
% The first parameter is the Origin of the route.
% The second parameter is the Destination of the route.
% The third parameter is the Criterion, either 'price' of 'duration'.
% The fourth parameter is the given flight route, which may or may not be the optimal one.
% The fifth parameter is the optimal flight route.
% findBestTrip(+Origin, +Destination, +Criterion, +Route, ?MinRoute)
findBestTrip(Origin,Destination,Criterion,[Price,Dur,N,Path],[MinPrice,MinDur,MinN,MinPath]) :-
	trip(Origin,Destination,[Price,Dur,N,Path]),
	findTrip(Origin,Destination,Criterion,Price,[Price2,Dur2,N2,Path2]),
	isABetterTrip(Criterion, Price, Price2, Dur, Dur2),!,
	% find a single example of a cheaper flight and call it again. Should these all fail, then it will try to max the 
	% patterns below, indicating it is the cheapest.
	findBestTrip(Origin,Destination,Criterion,[Price2,Dur2,N2,Path2],[MinPrice,MinDur,MinN,MinPath]).
findBestTrip(_,_,_,MinRoute,MinRoute).