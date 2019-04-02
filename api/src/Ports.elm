port module Ports exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode


type alias Identifier =
    String


type alias StatusCode =
    Int


port sendJson : ( StatusCode, Encode.Value ) -> Cmd msg


port dbQuery : ( Identifier, String, List String ) -> Cmd msg


port dbResult : (( Identifier, Decode.Value ) -> msg) -> Sub msg
