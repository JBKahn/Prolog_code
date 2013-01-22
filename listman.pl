/** wellFormedPath defines a well formed path as a path where the flights
are connected by location such that the destination of flight i is the
departure location of flight i + 1.
Parameters: The first paremeter is a well formed path.
Pre condition: THe list */
wellFormedPath([]).
/** The empty list is a well formed path.*/
wellFormedPath([[_, _,_]]).
/** A well formed path must be of an existing flight.*/
wellFormedPath([[_, _,City2]|[[City3, _,_] |Xs]]):- 
	City2=City3, Xs = [].
/** This covers a special case in the recursion where the list is only two
items long. The two flights are checked for existance, that the destination
and departure location match.*/
wellFormedPath([[_, _,City2]|[[City3, _,City4] |Xs]]):-
	City2=City3, not(Xs = []),
	append([[_,_,City4]],Xs,Sx),
	wellFormedPath(Sx).
/** If the list is more than two items long, the flight is checked for
existance, that the destination of the first flight and departure of the
next flight location match.*/


/** reverselist defines the reverse of a list.
Parameters: The first paremeter is a lsit. The second parameter is the list
which the reverselist is to be appended (usually the empty list) and the
third paremeter is the reverse of the first list.*/
reverselist([Car|Cdr],Newlst,Revlist) :- 
	reverselist(Cdr,[Car|Newlst],Revlist).
reverselist([],Revlist,Revlist).


/** remove_last defines the list where a last element has been removed
Parameters: The first elmenet is the orignal list and the second paremeter
is the same list with the last element removed.*/
remove_last([_], []).
remove_last([Head|Tail], [Head|TailB]):- remove_last(Tail, TailB).


/** Defines the reversePath of a flightpath.
Paremeters: The first parameter is a flight path and the second parameter is
the reverse of the first flightpath.
reversepath(+Path1,?Path2)*/
reversePath(X,Y) :- length(X,A), length(Y,A), reversePathhelper(X,Y).
/** A list X is a reverse of list Y if they have the same length.*/

/** Defines the reverse of a flightpath of two equal size paths.
Paremeters: The first parameter is a flight path and the second parameter is
the reverse of the first flightpath.*/
reversePathhelper([],_).
/** The empty list is its own reverse.*/
reversePathhelper([[]],_).
/** The recursive case where there are no more elements to comapare to.*/
reversePathhelper([[A,B,C]|As],D) :- 
	member([C,B,A],D), 
	remove_last(D,Dl), 
	reversePathhelper(As,Dl).
/** Specifies that the reversed list must have the reversed version of the first
path within D and this must be true for every sublist of D.*/