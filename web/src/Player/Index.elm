module Player.Index exposing (..)

import Data.Player exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ui exposing (..)
import Route
import Http
import Json.Decode as Decode
import Config exposing (..)


-- MODEL


type alias Model =
    List Player


init : Config -> ( Model, Cmd Msg )
init config =
    ( [], getPlayers config.api )



-- VIEW


view : Model -> Html msg
view players =
    div []
        [ h1 [ look HeadingLarge, spacing ExtraLarge ] [ text "Players" ]
        , viewPlayers (List.reverse players)
        ]


viewPlayers : Model -> Html msg
viewPlayers players =
    case players of
        [] ->
            div [ class "spacing--l" ] [ text "No players" ]

        _ ->
            div [ class "spacing--l" ] (List.map viewPlayer players)


viewPlayer : Player -> Html msg
viewPlayer player =
    div
        [ spacing Medium ]
        [ a
            [ Route.href (Route.PlayerShow player.id), inline Medium ]
            [ text (player.name ++ " ") ]
        ]



-- UPDATE


type Msg
    = PlayersReceived (Result Http.Error Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlayersReceived result ->
            case result of
                Ok players ->
                    ( players, Cmd.none )

                Err error ->
                    Debug.crash (toString error)



-- HELPERS


getPlayers : String -> Cmd Msg
getPlayers api =
    Http.get (api ++ "/players") (Decode.list decodePlayer)
        |> Http.send PlayersReceived
