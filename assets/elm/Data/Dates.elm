module Data.Dates exposing (..)

import Date exposing (..)
import Date.Extra exposing (..)
import Types exposing (..)
import Task
import Time exposing (..)


setCurrentDate : Time -> Model -> Model
setCurrentDate today model =
    { model | today = Just <| fromTime today }


handleSelectedDate : DateRange -> Model -> Model
handleSelectedDate dateRange model =
    { model | selectedDate = dateRange }


datesList : List DateRange
datesList =
    [ Today
    , ThisWeek
    , ThisMonth
    , All
    ]


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform CurrentDate Time.now


filterByDate : Model -> List Event -> List Event
filterByDate { selectedDate, today } =
    case selectedDate of
        Today ->
            List.filter <| isEventBefore Day today

        ThisWeek ->
            List.filter <| isEventBefore Week today

        ThisMonth ->
            List.filter <| isEventBefore Month today

        All ->
            allEvents


allEvents : List Event -> List Event
allEvents =
    identity


isEventBefore : Interval -> Maybe Date -> Event -> Bool
isEventBefore interval today event =
    Just (event.time)
        |> Maybe.map3 isBetween today (Maybe.map (Date.Extra.ceiling interval) today)
        |> Maybe.withDefault False


noEventsInDateRange : DateRange -> String
noEventsInDateRange dateRange =
    case dateRange of
        Today ->
            "No events near you today"

        ThisWeek ->
            "No events near you this week"

        ThisMonth ->
            "No events near you this month"

        All ->
            "No events found"


dateRangeToString : DateRange -> String
dateRangeToString dateRange =
    case dateRange of
        Today ->
            "Today"

        ThisWeek ->
            "This week"

        ThisMonth ->
            "This month"

        All ->
            "All events"


displayDate : Date -> String
displayDate date =
    Date.Extra.toFormattedString "MMMM d, h:mm a" date
