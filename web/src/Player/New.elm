module Player.New exposing (..)

import Data.Player exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ui exposing (..)
import Dom
import Task
import Http
import Json.Encode as Encode
import Config exposing (..)
import Route


-- MODEL


type alias Model =
    { name : String
    , health : String
    , damage : String
    , loading : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { health = "0", damage = "0", name = "", loading = False }
    , Dom.focus "focus" |> Task.attempt FocusResult
    )



-- VIEW


view : Model -> Html Msg
view model =
    let
        remainingPoints =
            totalPoints - toInt model.health - toInt model.damage

        valid =
            remainingPoints /= 0
    in
        div []
            [ h1
                [ look HeadingLarge, spacing ExtraLarge ]
                [ text "New Player" ]
            , form_
                [ onSubmit Submit, spacing Large ]
                [ div [ spacing Large ]
                    [ inputField
                        "Name"
                        [ id "focus", onInput ChangeName, value model.name ]
                    , inputField
                        "Health"
                        [ type_ "number", onInput ChangeHealth, value model.health ]
                    , inputField
                        "Damage"
                        [ type_ "number", onInput ChangeDamage, value model.damage ]
                    ]
                , div
                    [ spacing Large ]
                    [ text ("Points left: " ++ toString remainingPoints) ]
                , button
                    [ disabled (or ( True, valid ) model.loading)
                    , type_ "submit"
                    , look ButtonPrimary
                    , spacing Large
                    ]
                    [ text (or ( "Loading...", "Create Player" ) model.loading) ]
                ]
            ]


or : ( a, a ) -> Bool -> a
or ( true, false ) bool =
    case bool of
        True ->
            true

        False ->
            false



-- UPDATE


type Msg
    = ChangeHealth String
    | ChangeDamage String
    | ChangeName String
    | FocusResult (Result Dom.Error ())
    | Submit
    | PlayerCreated (Result Http.Error Player)


update : Config -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    case msg of
        ChangeHealth health ->
            ( { model | health = health }, Cmd.none )

        ChangeDamage damage ->
            ( { model | damage = damage }, Cmd.none )

        ChangeName name ->
            ( { model | name = name }, Cmd.none )

        FocusResult result ->
            ( model, Cmd.none )

        Submit ->
            ( { model | loading = True }
            , createPlayer config.api model
            )

        PlayerCreated result ->
            case result of
                Ok player ->
                    ( { model | loading = False }
                    , Route.load Route.PlayerIndex
                    )

                Err _ ->
                    Debug.crash "ERROR"



-- HELPERS


totalPoints : Int
totalPoints =
    150


createPlayer : String -> Model -> Cmd Msg
createPlayer api model =
    Http.post (api ++ "/players") (Http.jsonBody (encodeBody model)) decodePlayer
        |> Http.send PlayerCreated


encodeBody : Model -> Encode.Value
encodeBody model =
    Encode.object
        [ ( "name", Encode.string model.name )
        , ( "health", Encode.int <| toInt model.health )
        , ( "damage", Encode.int <| toInt model.damage )
        ]


toInt : String -> Int
toInt string =
    String.toInt string
        |> Result.withDefault 0
