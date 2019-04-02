module Page exposing (..)

import Battle.Show
import Battle.New
import Data.Player exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)
import Player.Index
import Player.New
import Player.Show
import NotFound
import Config exposing (Config)


-- MODEL


type Model
    = PageBattleNew Battle.New.Model
    | PageBattleShow Battle.Show.Model
    | PagePlayerIndex Player.Index.Model
    | PagePlayerShow Player.Show.Model
    | PagePlayerNew Player.New.Model
    | PageNotFound


init : Config -> Maybe Route -> ( Model, Cmd Msg )
init config route =
    setRoute config route



-- UPDATE


type Msg
    = MsgPlayerNew Player.New.Msg
    | MsgPlayerIndex Player.Index.Msg
    | MsgPlayerShow Player.Show.Msg
    | MsgBattleNew Battle.New.Msg
    | MsgBattleShow Battle.Show.Msg


update : Config -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    case msg of
        MsgPlayerNew subMsg ->
            case model of
                PagePlayerNew subModel ->
                    Player.New.update config subMsg subModel
                        |> Tuple.mapFirst PagePlayerNew
                        |> Tuple.mapSecond (Cmd.map MsgPlayerNew)

                _ ->
                    ( model, Cmd.none )

        MsgPlayerIndex subMsg ->
            case model of
                PagePlayerIndex subModel ->
                    Player.Index.update subMsg subModel
                        |> Tuple.mapFirst PagePlayerIndex
                        |> Tuple.mapSecond (Cmd.map MsgPlayerIndex)

                _ ->
                    ( model, Cmd.none )

        MsgPlayerShow subMsg ->
            case model of
                PagePlayerShow subModel ->
                    Player.Show.update subMsg subModel
                        |> Tuple.mapFirst PagePlayerShow
                        |> Tuple.mapSecond (Cmd.map MsgPlayerShow)

                _ ->
                    ( model, Cmd.none )

        MsgBattleNew subMsg ->
            case model of
                PageBattleNew subModel ->
                    Battle.New.update config subMsg subModel
                        |> Tuple.mapFirst PageBattleNew
                        |> Tuple.mapSecond (Cmd.map MsgBattleNew)

                _ ->
                    ( model, Cmd.none )

        MsgBattleShow subMsg ->
            case model of
                PageBattleShow subModel ->
                    Battle.Show.update subMsg subModel
                        |> Tuple.mapFirst PageBattleShow
                        |> Tuple.mapSecond (Cmd.map MsgBattleShow)

                _ ->
                    ( model, Cmd.none )


setRoute : Config -> Maybe Route -> ( Model, Cmd Msg )
setRoute config maybeRoute =
    case maybeRoute of
        Just route ->
            case route of
                Route.PlayerIndex ->
                    Player.Index.init config
                        |> Tuple.mapFirst PagePlayerIndex
                        |> Tuple.mapSecond (Cmd.map MsgPlayerIndex)

                Route.PlayerNew ->
                    Player.New.init
                        |> Tuple.mapFirst PagePlayerNew
                        |> Tuple.mapSecond (Cmd.map MsgPlayerNew)

                Route.PlayerShow id ->
                    Player.Show.init config id
                        |> Tuple.mapFirst PagePlayerShow
                        |> Tuple.mapSecond (Cmd.map MsgPlayerShow)

                Route.BattleNew ->
                    Battle.New.init
                        |> Tuple.mapFirst PageBattleNew
                        |> Tuple.mapSecond (Cmd.map MsgBattleNew)

                Route.BattleShow id ->
                    Battle.Show.init config id
                        |> Tuple.mapFirst PageBattleShow
                        |> Tuple.mapSecond (Cmd.map MsgBattleShow)

        Nothing ->
            ( PageNotFound, Cmd.none )



-- VIEW


view : Maybe Player -> Model -> Html Msg
view maybePlayer model =
    div []
        [ viewHeader maybePlayer
        , viewNavigation model
        , viewPage maybePlayer model
        ]


viewHeader : Maybe Player -> Html Msg
viewHeader maybePlayer =
    case maybePlayer of
        Just player ->
            div [ class "spacing--l" ]
                [ text "Playing as "
                , span [ class "color--primary" ] [ text player.name ]
                ]

        Nothing ->
            div [] []


viewNavigation : Model -> Html Msg
viewNavigation model =
    div [ class "spacing--xl" ]
        [ a
            [ classList
                [ ( "inline--m", True )
                , ( "button--secondary", True )
                ]
            , Route.href Route.BattleNew
            ]
            [ text "Battle" ]
        , a
            [ classList
                [ ( "inline--m", True )
                , ( "button--secondary", True )
                ]
            , Route.href Route.PlayerIndex
            ]
            [ text "Players" ]
        , a
            [ classList
                [ ( "inline--m", True )
                , ( "button--secondary", True )
                ]
            , Route.href Route.PlayerNew
            ]
            [ text "New Player" ]
        ]


viewPage : Maybe Player -> Model -> Html Msg
viewPage maybePlayer model =
    case model of
        PageBattleShow subModel ->
            Battle.Show.view subModel
                |> Html.map MsgBattleShow

        PageBattleNew subModel ->
            Battle.New.view maybePlayer subModel
                |> Html.map MsgBattleNew

        PagePlayerIndex subModel ->
            Player.Index.view subModel

        PagePlayerShow subModel ->
            Player.Show.view subModel
                |> Html.map MsgPlayerShow

        PagePlayerNew subModel ->
            Player.New.view subModel
                |> Html.map MsgPlayerNew

        PageNotFound ->
            NotFound.view
