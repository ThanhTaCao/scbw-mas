cost("Terran Supply Depot", 100, 0).
cost("Terran Barracks", 150, 0).
cost("Terran Academy", 150, 0).
cost("Terran Engineering Bay", 125, 0).
cost("Terran Bunker", 100, 0).
cost("Terran Refinery", 100, 0).

condition("Terran Supply Depot") :- supply(C, Max) & Max - C < 3.
condition("Terran Barracks") :- .findall(_, friendly(_, "Terran Barracks", _, _, _, _, _), L) & .length(L,N) & N < 2 & supply(_, Max) & Max > 10.
condition("Terran Academy") :- not(friendly(_, "Terran Academy", _, _, _, _, _)) & friendly(_, "Terran Barracks", _,_,_, _, _).
condition("Terran Engineering Bay") :- not(friendly(_, "Terran Engineering Bay", _, _, _, _, _)) & friendly(_, "Terran Barracks", _,_,_, _, _).
condition("Terran Bunker") :- friendly(_, "Terran Barracks", _,_,_, _, _).


canBuild(Building, X, Y) 
	:- 	cost(Building, M, G) & 
		minerals(MQ) & M <= MQ &
		gas(GQ) & G <= GQ &
		friendly(_, "Terran Command Center", Id, _, _, _, _) & 
		jia.findBuildingLocation(Id, Building, X, Y) & 
		buildTilePosition(MyX,MyY) & 
		jia.tileDistance(MyX,MyY,X,Y,D) &
		.findall([OtherX,OtherY,OtherD], (friendly(Name, "Terran SCV", _, _, _, OtherX, OtherY) & jia.tileDistance(OtherX,OtherY,X,Y,OtherD) & OtherD < D), []).

	
+constructing <- -building(_).

+!work
	:	building(Building) | constructing
	<-	.wait(1000); !!work.
+!work
	:	canBuild(Building, X, Y)
	<-	!build(Building, X, Y); .wait(1000); !!work.
+!work
	:	Building = "Terran Refinery" &
		vespeneGeyser(Id, _, _, X, Y) & 
		friendly(_, "Terran Supply Depot", _, _, _, _, _)
	<-	!build(Building, X, Y); .wait(1000); !!work.
+!work
	:	friendly(_, "Terran Refinery", Id, _, _, _, _) &
		.findall(_, gathering(_, vespene), L) & .length(L, N) & N < 3
	<-	gather(Id); .wait(1000); !!work.
+!gather 
	:	not(gathering(_)) & 
		.findall(Id,mineralField(Id,_,_,_,_) , L)&
		id(MyId)&
		jia.closest(MyId,L,ClosestId)
	<-	.print("gather");gather(ClosestId); .wait(1000).
+!work <- .wait(200); !work.
-!work <- .wait(200); !work.

+!gather <- .wait(200); !gather.
-!gather <- .wait(200); !gather.

+!build(Building, X, Y)
	:	cost(Building, M, G) & 
		minerals(MQ) & M <= MQ &
		gas(GQ) & G <= GQ
	<-	+building(Building); build(Building, X, Y).
+!build(Building, X, Y)
	<-	.wait(200); !build(Building, X, Y).
	
+!scouting
	:	map(MapWidth,MapHeight)& 
		.random(Rand1)& X = Rand1 * MapWidth &
		.random(Rand2)& Y = Rand2 * MapHeight
	<-	move(X,Y); .wait(5000); !scouting. 