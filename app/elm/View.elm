module View exposing (..)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Navbar exposing (navbar)
import Views.Location exposing (location)
import Views.Events exposing (events)
import Views.Search exposing (search)


view : Model -> Html Msg
view model =
    div [ class "flex" ]
        [ navbar model
        , div [ class "w-100" ]
            [ div [ class "flex" ] []
            , location model
            ]
        ]
