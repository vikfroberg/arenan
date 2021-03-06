module PlayerShow exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Ports


-- MODEL


type alias Model =
    {}


init : Int -> ( Model, Cmd Msg )
init id =
    ( {}
    , Ports.dbQuery
        ( "player"
        , "SELECT * FROM players WHERE id = $1"
        , [ toString id ]
        )
    )


type Msg
    = DatabaseResult ( String, Decode.Value )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DatabaseResult ( id, value ) ->
            let
                decoder =
                    Decode.list Decode.value

                resultData =
                    Decode.decodeValue decoder value
                        |> Result.andThen (List.head >> Result.fromMaybe "Could not find head")
            in
                case resultData of
                    Ok data ->
                        ( model
                        , Ports.sendJson ( 200, data )
                        )

                    Err error ->
                        ( model
                        , Ports.sendJson ( 402, Encode.string error )
                        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.dbResult DatabaseResult
