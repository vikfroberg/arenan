module Route exposing (..)

import Html
import Html.Attributes
import Navigation
import UrlParser as Url exposing ((</>))


type Route
    = PlayerIndex
    | PlayerNew
    | PlayerShow Int
    | BattleNew
    | BattleShow Int


toRoute : Url.Parser (Route -> a) a
toRoute =
    Url.oneOf
        [ Url.map PlayerIndex Url.top
        , Url.map PlayerIndex (Url.s "players")
        , Url.map PlayerNew (Url.s "players" </> Url.s "new")
        , Url.map PlayerShow (Url.s "players" </> Url.int)
        , Url.map BattleNew (Url.s "battles" </> Url.s "new")
        , Url.map BattleShow (Url.s "battles" </> Url.int)
        ]


routeToString : Route -> String
routeToString route =
    let
        pieces =
            case route of
                PlayerIndex ->
                    [ "players" ]

                PlayerNew ->
                    [ "players", "new" ]

                PlayerShow id ->
                    [ "players", toString id ]

                BattleShow id ->
                    [ "battles", toString id ]

                BattleNew ->
                    [ "battles", "new" ]
    in
        "/" ++ String.join "/" pieces


href : Route -> Html.Attribute msg
href route =
    Html.Attributes.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


load : Route -> Cmd msg
load =
    routeToString >> Navigation.load


fromLocation : Navigation.Location -> Maybe Route
fromLocation location =
    Url.parsePath toRoute location
