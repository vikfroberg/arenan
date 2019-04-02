module BattleCreate exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Time exposing (Time)
import Task
import Ports
import Random
import List.Extra


-- MODEL


type alias Model =
    {}


init : Decode.Value -> ( Model, Cmd Msg )
init bodyValue =
    case Decode.decodeValue decodeBody bodyValue of
        Ok body ->
            ( {}
            , Ports.dbQuery
                ( "selectPlayers"
                , """
                      SELECT id, name, health, damage FROM players
                      WHERE id IN (
                          SELECT id FROM players
                          WHERE NOT id = $1
                          ORDER BY random()
                          LIMIT 1
                      )
                      OR id = $1
                      ORDER BY id = $1 DESC
                      """
                , [ toString body.id ]
                )
            )

        Err error ->
            ( {}
            , Ports.sendJson ( 400, Encode.string error )
            )


type alias Body =
    { id : Int
    }


decodeBody : Decode.Decoder Body
decodeBody =
    Decode.map Body
        (Decode.field "id" Decode.int)


type alias Player =
    { name : String }


type alias Team =
    List Player


type Event
    = Attack
    | GiveUp



-- [ [ p1 ], [ p2, p3 ], [ p4 ] ]


round : List Team -> List Event
round teams =
    [ Attack ]



-- UPDATE


type Msg
    = DatabaseResult ( String, Decode.Value )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.dbResult DatabaseResult



-- SAVE TEAM IN JSON
-- SAVE OTHER DATA AS NEEDED
-- MODEL
-- type alias Model =
--     {}
-- type alias Body =
--     { id : Int
--     }
-- decodeBody : Decode.Decoder Body
-- decodeBody =
--     Decode.map Body
--         (Decode.field "id" Decode.int)
-- type alias Player =
--     { id : Int
--     , name : String
--     , health : Int
--     , damage : Int
--     , team : Int
--     }
-- decodePlayer : Int -> Decode.Decoder Player
-- decodePlayer team =
--     Decode.map5
--         Player
--         (Decode.field "id" Decode.int)
--         (Decode.field "name" Decode.string)
--         (Decode.field "health" Decode.int)
--         (Decode.field "damage" Decode.int)
--         (Decode.succeed team)
-- encodePlayer : Player -> Encode.Value
-- encodePlayer player =
--     Encode.object
--         [ ( "id", Encode.int player.id )
--         , ( "name", Encode.string player.name )
--         , ( "health", Encode.int player.health )
--         , ( "damage", Encode.int player.damage )
--         , ( "team", Encode.int player.team )
--         ]
-- type alias PlayerPair =
--     { home : Player
--     , away : Player
--     }
-- decodePlayerPair : Decode.Decoder PlayerPair
-- decodePlayerPair =
--     Decode.map2 PlayerPair
--         (Decode.index 0 (decodePlayer 0))
--         (Decode.index 1 (decodePlayer 1))
-- type alias Report =
--     { teams : PlayerPair
--     , rounds : List Round
--     }
-- encodeReport report =
--     Encode.list
--         (List.indexedMap encodeRound report)
-- type Round
--     = Round (List Action)
-- encodeRound index round =
--     case round of
--         Round actions ->
--             Encode.list
--                 (List.indexedMap encodeAction actions)
-- type Action
--     = Attack Player Int Player
--     | End Player Player
-- encodeAction index action =
--     case action of
--         End winner looser ->
--             Encode.object
--                 [ ( "id", Encode.int index )
--                 , ( "type", Encode.string "END" )
--                 , ( "winner", encodePlayer winner )
--                 , ( "looser", encodePlayer looser )
--                 ]
--         Attack giver damage taker ->
--             Encode.object
--                 [ ( "id", Encode.int index )
--                 , ( "type", Encode.string "ATTACK" )
--                 , ( "giver", encodePlayer giver )
--                 , ( "damage", Encode.int damage )
--                 , ( "taker", encodePlayer taker )
--                 ]
-- init : Decode.Value -> ( Model, Cmd Msg )
-- init bodyValue =
--     case Decode.decodeValue decodeBody bodyValue of
--         Ok body ->
--             ( {}
--             , Ports.dbQuery
--                 ( "selectPlayers"
--                 , """
--                       SELECT id, name, health, damage FROM players
--                       WHERE id IN (
--                           SELECT id FROM players
--                           WHERE NOT id = $1
--                           ORDER BY random()
--                           LIMIT 1
--                       )
--                       OR id = $1
--                       ORDER BY id = $1 DESC
--                       """
--                 , [ toString body.id ]
--                 )
--             )
--         Err error ->
--             ( {}
--             , Ports.sendJson ( 400, Encode.string error )
--             )
-- -- UPDATE
-- type Msg
--     = CreateBattle PlayerPair Time
--     | DatabaseResult ( String, Decode.Value )
-- update : Msg -> Model -> ( Model, Cmd Msg )
-- update msg model =
--     case msg of
--         CreateBattle players time ->
--             let
--                 seed =
--                     round time
--                 report =
--                     generateReport seed players
--                 roundActions entry =
--                     case entry of
--                         Round actions ->
--                             actions
--                 pickWinner action =
--                     case action of
--                         End winner looser ->
--                             Just winner
--                         Attack _ _ _ ->
--                             Nothing
--                 maybeWinner =
--                     List.Extra.last report
--                         |> Maybe.map roundActions
--                         |> Maybe.andThen List.Extra.last
--                         |> Maybe.andThen pickWinner
--             in
--                 case maybeWinner of
--                     Just winner ->
--                         ( model
--                         , Ports.dbQuery
--                             ( "insertBattle"
--                             , """
--                             INSERT INTO battles (home_id, away_id, winner_id, report)
--                             VALUES ($1, $2, $3, $4)
--                             RETURNING id
--                             """
--                             , [ toString players.home.id
--                               , toString players.away.id
--                               , toString winner.id
--                               , Encode.encode 0 (encodeReport report)
--                               ]
--                             )
--                         )
--                     Nothing ->
--                         Debug.crash "Should have a winner"
--         DatabaseResult ( id, value ) ->
--             case id of
--                 "selectPlayers" ->
--                     case Decode.decodeValue decodePlayerPair value of
--                         Ok players ->
--                             ( model
--                             , Task.perform (CreateBattle players) Time.now
--                             )
--                         Err error ->
--                             Debug.crash (toString error)
--                 "insertBattle" ->
--                     let
--                         decoder =
--                             Decode.list Decode.value
--                         result =
--                             Decode.decodeValue decoder value
--                                 |> Result.andThen (List.head >> Result.fromMaybe "Could not find head")
--                     in
--                         case result of
--                             Ok battle ->
--                                 ( model
--                                 , Ports.sendJson ( 200, battle )
--                                 )
--                             Err error ->
--                                 Debug.crash (toString error)
--                 _ ->
--                     Debug.crash ("Unhandled DatabaseResult of id: " ++ id)
-- -- SUBSCRIPTIONS
-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--     Ports.dbResult DatabaseResult
-- -- HELPERS
-- generateReport : Int -> PlayerPair -> Report
-- generateReport seed playerPair =
--     let
--         seed1 =
--             Random.initialSeed seed
--         report =
--             { teams = [ [ playerPair.home ], [ playerPair.away ] ]
--             , rounds = []
--             }
--         ( rounds, seed2 ) =
--             generateRound ( report, seed1 )
--     in
--         rounds
-- generateRound : ( Report, Random.Seed ) -> ( Report, Random.Seed )
-- generateRound ( report, seed1 ) =
--     let
--         ( ( firstPlayer, secondPlayer ), seed2 ) =
--             Random.bool
--                 |> Random.map
--                     (\b ->
--                         if b then
--                             ( report.teams.home, report.teams.away )
--                         else
--                             ( report.teams.away, report.teams.home )
--                     )
--                 |> (\gen -> Random.step gen seed1)
--         ( firstPlayerHp, _ ) =
--             List.foldl hpAfterRound firstPlayer report.rounds
--         ( secondPlayerHp, _ ) =
--             List.foldl hpAfterRound ( secondPlayer.health, secondPlayer ) report.rounds
--         ( firstPlayerDmg, seed3 ) =
--             Random.int 0 firstPlayer.damage
--                 |> (\gen -> Random.step gen seed2)
--         ( secondPlayerDmg, seed4 ) =
--             Random.int 0 secondPlayer.damage
--                 |> (\gen -> Random.step gen seed3)
--         firstPlayerAttack =
--             Attack firstPlayer firstPlayerDmg secondPlayer
--         secondPlayerAttack =
--             Attack secondPlayer secondPlayerDmg firstPlayer
--     in
--         if secondPlayerHp - firstPlayerDmg <= 0 then
--             ( { report
--                 | rounds = report.rounds ++ [ Round [ firstPlayerAttack, End firstPlayer secondPlayer ] ]
--               }
--             , seed4
--             )
--         else if firstPlayerHp - secondPlayerDmg <= 0 then
--             ( { report
--                 | rounds = report.rounds ++ [ Round [ firstPlayerAttack, secondPlayerAttack, End secondPlayer firstPlayer ] ]
--               }
--             , seed4
--             )
--         else
--             generateRound
--                 ( { report
--                     | rounds = report.rounds ++ [ Round [ firstPlayerAttack, secondPlayerAttack ] ]
--                   }
--                 , seed4
--                 )
-- hpAfterRound : Round -> Player -> Int
-- hpAfterRound round ( health, player ) =
--     case round of
--         Round actions ->
--             List.foldl hpAfterAction ( health, player ) actions
--                 |> Tuple.first
-- hpAfterAction : Action -> ( Int, Player ) -> ( Int, Player )
-- hpAfterAction action ( health, player ) =
--     case action of
--         Attack initiator damage taker ->
--             if taker == player then
--                 ( health - damage, player )
--             else
--                 ( health, player )
--         End _ _ ->
--             ( health, player )
