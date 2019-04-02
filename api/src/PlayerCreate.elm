module PlayerCreate exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Ports


-- MODEL


type alias Model =
    {}


type alias Body =
    { name : String
    , health : Int
    , damage : Int
    }


bodyDecoder =
    Decode.map3 Body
        (Decode.field "name" Decode.string)
        (Decode.field "health" Decode.int)
        (Decode.field "damage" Decode.int)


init : Decode.Value -> ( Model, Cmd Msg )
init value =
    let
        resultBody =
            Decode.decodeValue bodyDecoder value
    in
        case resultBody of
            Ok body ->
                ( {}
                , Ports.dbQuery
                    ( "insertPlayer"
                    , """
                      INSERT INTO players (name, health, damage)
                      VALUES ($1, $2, $3)
                      RETURNING id, name, health, damage
                      """
                    , [ body.name, toString body.health, toString body.damage ]
                    )
                )

            Err error ->
                ( {}
                , Ports.sendJson ( 400, Encode.string error )
                )



-- UPDATE


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
