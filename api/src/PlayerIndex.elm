module PlayerIndex exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Ports


-- MODEL


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}
    , Ports.dbQuery
        ( "players"
        , "SELECT id, name, health, damage FROM players"
        , []
        )
    )



-- UPDATE


type Msg
    = DatabaseResult ( String, Decode.Value )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DatabaseResult ( id, value ) ->
            ( model
            , Ports.sendJson ( 200, value )
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.dbResult DatabaseResult
