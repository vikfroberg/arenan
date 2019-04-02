module Ui exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


inputField : String -> List (Attribute msg) -> Html msg
inputField title attributes =
    div [ spacing Medium ]
        [ label [ look TextPrimary, spacing Small ] [ text title ]
        , input ([ look Input ] ++ attributes) []
        ]


type Look
    = ButtonPrimary
    | ButtonSecondary
    | HeadingLarge
    | TextPrimary
    | TextSecondary
    | Input


type Size
    = Small
    | Medium
    | Large
    | ExtraLarge


look : Look -> Attribute msg
look a =
    case a of
        ButtonPrimary ->
            class "button--primary"

        ButtonSecondary ->
            class "button--secondary"

        HeadingLarge ->
            class "heading--l"

        TextPrimary ->
            class "color--primary"

        TextSecondary ->
            class "color--secondary"

        Input ->
            class "input"


spacing : Size -> Attribute msg
spacing a =
    case a of
        Small ->
            class "spacing--s"

        Medium ->
            class "spacing--m"

        Large ->
            class "spacing--l"

        ExtraLarge ->
            class "spacing--xl"


inline : Size -> Attribute msg
inline a =
    case a of
        Small ->
            class ""

        Medium ->
            class "inline--m"

        Large ->
            class ""

        ExtraLarge ->
            class ""


form_ : List (Attribute msg) -> List (Html msg) -> Html msg
form_ =
    Html.form
