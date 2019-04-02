module Entities exposing (..)

import SelectList exposing (SelectList)
import Task
import Time exposing (Time)
import Config exposing (..)
import Route
import List.Extra
import Random.List
import Random
import Data.Player exposing (Player)


-- MODEL


type alias Model =
    { battles : List Battle
    }


type alias Battle =
    { seed : Int
    , home : Player
    , away : Player
    , id : Int
    }


init : Config -> ( Model, Cmd Msg )
init config =
    ( { battles = [] }, Cmd.none )



-- UPDATE


type Msg
    = CreateBattle Player
    | CreateBattleWithTime Player Player Time


update : Config -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    case msg of
        CreateBattle player ->
            ( model
            , Task.perform (CreateBattleWithTime player player) Time.now
            )

        CreateBattleWithTime home away time ->
            let
                battle =
                    { home = home
                    , away = away
                    , seed = round time
                    , id = List.length model.battles
                    }
            in
                ( { model | battles = model.battles ++ [ battle ] }
                , Route.BattleShow battle.id |> Route.modifyUrl
                )



-- HELPERS


battles : Model -> List Battle
battles model =
    model.battles


findBattle : Int -> Model -> Maybe Battle
findBattle id model =
    find (\battle -> battle.id == id) model.battles


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    List.filter predicate list
        |> List.head
