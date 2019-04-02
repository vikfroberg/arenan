port module Ports exposing (..)

import Json.Encode


type alias Key =
    String


type alias Value =
    Json.Encode.Value


port storageGetItemResponse : (( Key, Value ) -> msg) -> Sub msg


port storageSetItemResponse : (( Key, Value ) -> msg) -> Sub msg


port storageGetItem : Key -> Cmd msg


port storageSetItem : ( Key, Value ) -> Cmd msg


port storageRemoveItem : Key -> Cmd msg


port storageClear : () -> Cmd msg
