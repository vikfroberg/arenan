module Data.Player exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Http


type alias Player =
    { health : Int
    , damage : Int
    , name : String
    , id : Int
    }


encodePlayer : Player -> Encode.Value
encodePlayer player =
    Encode.object
        [ ( "name", Encode.string player.name )
        , ( "health", Encode.int player.health )
        , ( "damage", Encode.int player.damage )
        ]


decodePlayer : Decode.Decoder Player
decodePlayer =
    Decode.map4
        Player
        (Decode.field "health" Decode.int)
        (Decode.field "damage" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "id" Decode.int)


getPlayer : (Result Http.Error Player -> msg) -> String -> Int -> Cmd msg
getPlayer msg api id =
    Http.get (api ++ "/players/" ++ toString id) decodePlayer
        |> Http.send msg
