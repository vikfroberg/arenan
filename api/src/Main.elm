module Main exposing (..)

import Platform
import Route exposing (Route)
import Json.Encode as Encode
import Json.Decode as Decode
import Navigation exposing (Location)
import PlayerIndex
import PlayerShow
import BattleShow
import PlayerCreate
import BattleCreate
import Ports


-- MODEL


type Model
    = PagePlayerIndex PlayerIndex.Model
    | PagePlayerShow PlayerShow.Model
    | PagePlayerCreate PlayerCreate.Model
    | PageBattleShow BattleShow.Model
    | PageBattleCreate BattleCreate.Model
    | PageNotFound


type alias Flags =
    { pathname : String
    , search : String
    , body : Decode.Value
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        location =
            toLocation flags.pathname flags.search

        route =
            Route.fromLocation location

        body =
            flags.body
    in
        case route of
            Just route ->
                case route of
                    Route.PlayerIndex ->
                        PlayerIndex.init
                            |> Tuple.mapFirst PagePlayerIndex
                            |> Tuple.mapSecond (Cmd.map MsgPlayerIndex)

                    Route.PlayerShow id ->
                        PlayerShow.init id
                            |> Tuple.mapFirst PagePlayerShow
                            |> Tuple.mapSecond (Cmd.map MsgPlayerShow)

                    Route.PlayerCreate ->
                        PlayerCreate.init body
                            |> Tuple.mapFirst PagePlayerCreate
                            |> Tuple.mapSecond (Cmd.map MsgPlayerCreate)

                    Route.BattleShow id ->
                        BattleShow.init id
                            |> Tuple.mapFirst PageBattleShow
                            |> Tuple.mapSecond (Cmd.map MsgBattleShow)

                    Route.BattleCreate ->
                        BattleCreate.init body
                            |> Tuple.mapFirst PageBattleCreate
                            |> Tuple.mapSecond (Cmd.map MsgBattleCreate)

            Nothing ->
                ( PageNotFound, Ports.sendJson ( 404, (Encode.string "Not Found") ) )



-- UPDATE


type Msg
    = MsgPlayerIndex PlayerIndex.Msg
    | MsgPlayerShow PlayerShow.Msg
    | MsgPlayerCreate PlayerCreate.Msg
    | MsgBattleShow BattleShow.Msg
    | MsgBattleCreate BattleCreate.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgPlayerIndex subMsg ->
            case model of
                PagePlayerIndex subModel ->
                    PlayerIndex.update subMsg subModel
                        |> Tuple.mapFirst PagePlayerIndex
                        |> Tuple.mapSecond (Cmd.map MsgPlayerIndex)

                _ ->
                    ( model, Cmd.none )

        MsgPlayerShow subMsg ->
            case model of
                PagePlayerShow subModel ->
                    PlayerShow.update subMsg subModel
                        |> Tuple.mapFirst PagePlayerShow
                        |> Tuple.mapSecond (Cmd.map MsgPlayerShow)

                _ ->
                    ( model, Cmd.none )

        MsgPlayerCreate subMsg ->
            case model of
                PagePlayerCreate subModel ->
                    PlayerCreate.update subMsg subModel
                        |> Tuple.mapFirst PagePlayerCreate
                        |> Tuple.mapSecond (Cmd.map MsgPlayerCreate)

                _ ->
                    ( model, Cmd.none )

        MsgBattleShow subMsg ->
            case model of
                PageBattleShow subModel ->
                    BattleShow.update subMsg subModel
                        |> Tuple.mapFirst PageBattleShow
                        |> Tuple.mapSecond (Cmd.map MsgBattleShow)

                _ ->
                    ( model, Cmd.none )

        MsgBattleCreate subMsg ->
            case model of
                PageBattleCreate subModel ->
                    BattleCreate.update subMsg subModel
                        |> Tuple.mapFirst PageBattleCreate
                        |> Tuple.mapSecond (Cmd.map MsgBattleCreate)

                _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        PagePlayerIndex subModel ->
            PlayerIndex.subscriptions subModel
                |> Sub.map MsgPlayerIndex

        PagePlayerShow subModel ->
            PlayerShow.subscriptions subModel
                |> Sub.map MsgPlayerShow

        PagePlayerCreate subModel ->
            PlayerCreate.subscriptions subModel
                |> Sub.map MsgPlayerCreate

        PageBattleShow subModel ->
            BattleShow.subscriptions subModel
                |> Sub.map MsgBattleShow

        PageBattleCreate subModel ->
            BattleCreate.subscriptions subModel
                |> Sub.map MsgBattleCreate

        PageNotFound ->
            Sub.none



-- PROGRAM


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- HELPERS


toLocation : String -> String -> Location
toLocation pathname search =
    { href = ""
    , host = ""
    , hostname = ""
    , protocol = ""
    , origin = ""
    , port_ = ""
    , pathname = pathname
    , search = search
    , hash = ""
    , username = ""
    , password = ""
    }
