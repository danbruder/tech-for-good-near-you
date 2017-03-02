module Views.Navbar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Views.Categories exposing (categories)


navbar : Model -> Html Msg
navbar model =
    nav [ class "bg-green pa3 white fixed-ns w5-ns vh-100-ns left-0 top-0" ]
        [ logo
        , p [ class "mt0 ml1" ] [ text "near you" ]
        , categories model
        ]


logo : Html Msg
logo =
    div [ class "w4" ] [ img [ class "w-100", src "/img/tech-for-good.png" ] [] ]
