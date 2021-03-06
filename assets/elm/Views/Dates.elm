module Views.Dates exposing (..)

import Data.Dates exposing (dateRangeToString, datesList)
import Helpers.Style exposing (px)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Types exposing (..)


type DateButton
    = SideBar
    | BottomBar
    | FullPage


dateBottomBarOptions : Model -> Html Msg
dateBottomBarOptions model =
    div [] <| List.map (dateButton BottomBar model) datesList


dateMainOptions : Model -> Html Msg
dateMainOptions model =
    div [ class "tc mt4" ] <| List.map (dateButton FullPage model) datesList


dateSideOptions : Model -> Html Msg
dateSideOptions model =
    div [ class "mt3-ns", style [ ( "width", px 120 ) ] ]
        [ p [ class "white" ] [ text "events from:" ]
        , div [] (List.map (dateButton SideBar model) datesList)
        ]


dateButton : DateButton -> Model -> DateRange -> Html Msg
dateButton buttonType model date =
    let
        ( bodyClasses, offClasses, onClasses ) =
            buttonClasses buttonType
    in
        div
            [ class ("br2 ba pointer t-3 t-bg-color ease no-select " ++ bodyClasses)
            , classList
                [ ( offClasses, date == model.selectedDate )
                , ( onClasses, date /= model.selectedDate )
                ]
            , onClick (SetDateRange date)
            ]
            [ span [ class "f6 fw4" ] [ text (dateRangeToString date) ] ]


buttonClasses : DateButton -> ( String, String, String )
buttonClasses buttonType =
    case buttonType of
        SideBar ->
            ( "b--white pv1 ph2 ma2 ml0", "bg-white green", "white" )

        BottomBar ->
            ( "b--white dib ma1 ph1 pb1", "bg-white green", "white" )

        FullPage ->
            ( "b--green pv2 ph5 ma2", "bg-green white", "green" )
