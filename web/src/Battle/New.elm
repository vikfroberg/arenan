module Battle.New exposing (..)

import Data.Player exposing (..)
import Ui exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Config exposing (Config)
import Json.Encode as Encode
import Json.Decode as Decode
import Route


-- MODEL


type alias Model =
    Bool


init : ( Model, Cmd Msg )
init =
    ( False, Cmd.none )



-- UPDATE


type Msg
    = Battle Player
    | BattleCreated (Result Http.Error Int)


update : Config -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    case msg of
        Battle player ->
            ( True, createBattle config.api player )

        BattleCreated result ->
            case result of
                Ok id ->
                    ( False, Route.load (Route.BattleShow id) )

                Err error ->
                    Debug.crash (toString error)


view : Maybe Player -> Model -> Html Msg
view maybePlayer model =
    case maybePlayer of
        Just player ->
            div
                []
                [ h1 [ look HeadingLarge, spacing Large ] [ text "Battle" ]
                , button
                    [ disabled model
                    , look ButtonPrimary
                    , onClick (Battle player)
                    ]
                    [ text
                        (if model then
                            "Finding opponent..."
                         else
                            "Battle"
                        )
                    ]
                ]

        Nothing ->
            h1 [ look HeadingLarge ] [ text "Choose a player" ]



-- HELPERS


createBattle : String -> Player -> Cmd Msg
createBattle api player =
    Http.post (api ++ "/battles") (Http.jsonBody (encodeBody player)) decodeId
        |> Http.send BattleCreated


decodeId : Decode.Decoder Int
decodeId =
    Decode.field "id" Decode.int


encodeBody : Player -> Encode.Value
encodeBody model =
    Encode.object
        [ ( "id", Encode.int model.id )
        ]
