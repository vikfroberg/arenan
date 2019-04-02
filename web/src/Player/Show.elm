module Player.Show exposing (..)

import Http
import Html exposing (..)
import Data.Player exposing (..)
import Ui exposing (..)
import Entities exposing (Battle)
import Route
import Ui exposing (..)
import Battle.Show
import List.Extra
import Config exposing (Config)


-- MODEL


type alias Model =
    Maybe Player


init : Config -> Int -> ( Model, Cmd Msg )
init config id =
    ( Nothing, getPlayer config.api id )



-- VIEW


view : Model -> Html Msg
view maybePlayer =
    case maybePlayer of
        Just player ->
            div
                []
                [ h1 [ look HeadingLarge, spacing Large ] [ text player.name ]
                , h2 [ look HeadingLarge, spacing Large ] [ text "Traits" ]
                , viewTraits player
                ]

        Nothing ->
            div [] [ text "Not Found" ]


viewTraits : Player -> Html msg
viewTraits player =
    div
        [ spacing ExtraLarge ]
        [ div [ spacing Small ] [ text "Health: ", text (toString player.health) ]
        , div [ spacing Small ] [ text "Damage: ", text (toString player.damage) ]
        ]



-- UPDATE


type Msg
    = PlayerReceived (Result Http.Error Player)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlayerReceived result ->
            case result of
                Ok player ->
                    ( Just player, Cmd.none )

                Err error ->
                    Debug.crash (toString error)



-- HELPERS


getPlayer : String -> Int -> Cmd Msg
getPlayer api id =
    Http.get (api ++ "/players/" ++ toString id) decodePlayer
        |> Http.send PlayerReceived
