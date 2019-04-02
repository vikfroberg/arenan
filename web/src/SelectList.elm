module SelectList exposing (..)


type alias SelectList a =
    { selected : Maybe a
    , list : List a
    }


select : a -> SelectList a -> SelectList a
select x selectList =
    case List.filter ((==) x) selectList.list of
        x :: [] ->
            { selectList | selected = Just x }

        _ ->
            selectList


deselect : SelectList a -> SelectList a
deselect selectList =
    { selectList | selected = Nothing }


push : a -> SelectList a -> SelectList a
push a selectList =
    { selectList | list = selectList.list ++ [ a ] }


selected : SelectList a -> Maybe a
selected =
    .selected


fromList : List a -> SelectList a
fromList list =
    { selected = Nothing, list = list }


toList : SelectList a -> List a
toList selectList =
    selectList.list
