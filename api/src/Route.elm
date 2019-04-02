module Route exposing (..)

import Navigation exposing (Location)
import UrlParser as Url exposing ((</>))


type Route
    = PlayerIndex
    | PlayerShow Int
    | PlayerCreate
    | BattleShow Int
    | BattleCreate


toRoute : Url.Parser (Route -> a) a
toRoute =
    Url.oneOf
        [ Url.map PlayerIndex (Url.s "GET" </> Url.s "players")
        , Url.map PlayerShow (Url.s "GET" </> Url.s "players" </> Url.int)
        , Url.map PlayerCreate (Url.s "POST" </> Url.s "players")
        , Url.map BattleShow (Url.s "GET" </> Url.s "battles" </> Url.int)
        , Url.map BattleCreate (Url.s "POST" </> Url.s "battles")
        ]


fromLocation : Location -> Maybe Route
fromLocation location =
    Url.parsePath toRoute location
