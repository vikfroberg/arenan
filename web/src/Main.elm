module Main exposing (main)

import Data.Player exposing (..)
import Html exposing (Html)
import Page
import Config exposing (..)
import Navigation exposing (Location)
import Tuple
import Route exposing (Route)
import Ports
import Http


-- MODEL


type alias Model =
    { page : Page.Model
    , player : Maybe Player
    , config : Config
    }


type alias Flags =
    { api : String
    , playerId : Maybe Int
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        config =
            { api = flags.api }

        ( pageModel, pageCmd ) =
            Page.init config (Route.fromLocation location)

        getPlayerCmd =
            case flags.playerId of
                Just id ->
                    getPlayer ReceivedPlayer config.api id

                Nothing ->
                    Cmd.none
    in
        { page = pageModel
        , config = config
        , player = Nothing
        }
            ! [ Cmd.map MsgPage pageCmd
              , getPlayerCmd
              ]



-- UPDATE


type Msg
    = MsgPage Page.Msg
    | SetRoute (Maybe Route)
    | ReceivedPlayer (Result Http.Error Player)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgPage subMsg ->
            Page.update model.config subMsg model.page
                |> Tuple.mapFirst (setPage model)
                |> Tuple.mapSecond (Cmd.map MsgPage)

        SetRoute route ->
            Page.setRoute model.config route
                |> Tuple.mapFirst (setPage model)
                |> Tuple.mapSecond (Cmd.map MsgPage)

        ReceivedPlayer result ->
            case result of
                Ok player ->
                    ( { model | player = Just player }, Cmd.none )

                Err error ->
                    Debug.crash (toString error)


setPage : Model -> Page.Model -> Model
setPage model page =
    { model | page = page }



-- VIEW


view : Model -> Html Msg
view model =
    Page.view model.player model.page
        |> Html.map MsgPage



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- PROGRAM


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
