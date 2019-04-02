module BattleCreate2 exposing (..)


type Team
    = Team1 Int


type Teams
    = Teams2 Team Team


type Event
    = Winner Int
    | GiveUp Int
    | Attack Int Int Int


attack : ( Int, Int, List Event ) -> Generator ( Int, Int, List Event )
attack ( giver, taker, events ) =
    if giver.health > 0 then
        Random.int 0 giver.damage
            |> Random.map
                (\dmg -> ( giver, taker - dmg, events ++ [ Attack giver dmg taker ] ))
    else
        Random.bool (always events)


flipPlayers : ( Int, Int, List Event ) -> ( Int, Int, List Event )
flipPlayers ( giver, taker, events ) =
    ( taker, giver, events )


giveUp : ( Int, Int, List Event ) -> ( Int, Int, Event )
giveUp ( giver, taker, events ) =
    if taker.health <= 0 then
        events ++ [ GiveUp taker ]
    else
        events


events : Teams -> ( List Events, Teams )
events teams =
    case teams of
        Teams2 team1 team2 ->
            case ( team1, team2 ) of
                ( Team1 t1p1, Team1 t2p1 ) ->
                    let
                        playerEventGen =
                            attack >> Random.map giveUp

                        eventsGen =
                            playerEventGen ( t1p1, t2p1, [] )
                                |> Random.map flipPlayers
                                |> Random.andThen playerEventGen
                                |> Random.map flipPlayers

                        ( ( t1p1_, t2p1_, events ), seed2 ) =
                            Random.step eventsGen seed1

                        teams_ =
                            Teams2 (Team1 t1p1_) (Team1 t2p1_)
                    in
                        if t2p1_.health <= 0 then
                            ( events ++ [ End t1p1 ], teams_ )
                        else if t1p1_.health <= 0 then
                            ( events ++ [ End t2p1 ], teams_ )
                        else
                            ( events, teams_ )


omg =
    events (Teams2 (Team2 1 2) (Team2 3 4)) []


main =
    ""
