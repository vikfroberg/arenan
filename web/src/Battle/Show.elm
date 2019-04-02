module Battle.Show exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ui exposing (..)
import Json.Decode as Decode
import Config exposing (..)
import Http


-- MODEL


type alias Model =
    { report : Maybe Report
    , round : Int
    }


init : Config -> Int -> ( Model, Cmd Msg )
init config id =
    ( { report = Nothing, round = 0 }
    , getReport config.api id
    )


type alias TeamPlayer =
    { health : Int
    , damage : Int
    , name : String
    , id : Int
    , team : Int
    }


decodeTeamPlayer : Decode.Decoder TeamPlayer
decodeTeamPlayer =
    Decode.map5
        TeamPlayer
        (Decode.field "health" Decode.int)
        (Decode.field "damage" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "id" Decode.int)
        (Decode.field "team" Decode.int)


type alias Report =
    List ReportEntry


decodeReport : Decode.Decoder Report
decodeReport =
    Decode.field "report" (Decode.list decodeReportEntry)


type ReportEntry
    = Round (List Action)


decodeReportEntry : Decode.Decoder ReportEntry
decodeReportEntry =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\type_ ->
                case type_ of
                    "ROUND" ->
                        decodeRound

                    _ ->
                        Decode.fail "Unkown type"
            )


decodeRound : Decode.Decoder ReportEntry
decodeRound =
    Decode.map Round
        (Decode.field "actions" (Decode.list decodeAction))


type Action
    = Attack TeamPlayer Int TeamPlayer
    | End TeamPlayer TeamPlayer


decodeAction : Decode.Decoder Action
decodeAction =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\type_ ->
                case type_ of
                    "ATTACK" ->
                        decodeAttack

                    "END" ->
                        decodeEnd

                    _ ->
                        Decode.fail "Unkown type"
            )


decodeEnd : Decode.Decoder Action
decodeEnd =
    Decode.map2 End
        (Decode.field "winner" decodeTeamPlayer)
        (Decode.field "looser" decodeTeamPlayer)


decodeAttack : Decode.Decoder Action
decodeAttack =
    Decode.map3 Attack
        (Decode.field "giver" decodeTeamPlayer)
        (Decode.field "damage" Decode.int)
        (Decode.field "taker" decodeTeamPlayer)



-- VIEW


view : Model -> Html Msg
view model =
    case model.report of
        Just report ->
            div
                []
                [ h1 [ look HeadingLarge, spacing ExtraLarge ] [ text "Battle!" ]
                , div
                    [ spacing ExtraLarge ]
                    (List.indexedMap viewReportEntry report)
                ]

        Nothing ->
            div [] [ text "Not Found" ]


viewReportEntry : Int -> ReportEntry -> Html msg
viewReportEntry index round =
    case round of
        Round actions ->
            div [ class "spacing--l" ]
                [ div [ class "heading--s spacing--m" ] [ text <| "Round " ++ toString (index + 1) ]
                , div [] (List.map viewAction actions)
                ]


viewAction : Action -> Html msg
viewAction action =
    case action of
        Attack giver damage taker ->
            div []
                [ span [ classForPlayer giver ] [ text giver.name ]
                , text " deals "
                , text <| "(" ++ toString damage ++ ")"
                , text " to "
                , span [ classForPlayer taker ] [ text taker.name ]
                , text "."
                ]

        End winner looser ->
            div []
                [ div [ class "spacing--l" ] []
                , div [ class "spacing--l" ]
                    [ span [ classForPlayer looser ] [ text looser.name ]
                    , text " decides to give up."
                    ]
                , div []
                    [ text "The stadium cheers for "
                    , span [ classForPlayer winner ] [ text winner.name ]
                    , text " who won this epic battle!"
                    ]
                ]



-- UPDATE


type Msg
    = ReportReceived (Result Http.Error Report)
    | NextRound


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NextRound ->
            ( { model | round = model.round + 1 }
            , Cmd.none
            )

        ReportReceived result ->
            case result of
                Ok report ->
                    ( { model | report = Just report }
                    , Cmd.none
                    )

                Err error ->
                    Debug.crash (toString error)



-- HELPERS


getReport : String -> Int -> Cmd Msg
getReport api id =
    Http.get (api ++ "/battles/" ++ toString id) decodeReport
        |> Http.send ReportReceived


classForPlayer : TeamPlayer -> Attribute msg
classForPlayer player =
    case player.team of
        0 ->
            look TextPrimary

        1 ->
            look TextSecondary

        _ ->
            Debug.crash "invalid team"
