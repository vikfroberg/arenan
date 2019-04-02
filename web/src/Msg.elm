module Msg exposing (..)

import Task


map2 : (c -> d) -> (a -> b -> c) -> (a -> b -> d)
map2 f1 f2 a b =
    f2 a b |> f1


map : (b -> c) -> (a -> b) -> (a -> c)
map f1 f2 =
    f1 << f2


perform : msg -> Cmd msg
perform =
    Task.perform identity << Task.succeed
