module Update exposing (..)

import Model exposing (..)
import Data.Events exposing (getEvents)
import Data.Location.Geo exposing (..)
import Data.Location.Postcode exposing (..)
import Data.Dates exposing (..)
import Data.Events exposing (..)
import Data.Ports exposing (..)
import Date exposing (..)
import Helpers.Delay exposing (..)
import Update.Extra.Infix exposing ((:>))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdatePostcode postcode ->
            { model | postcode = validatePostcode postcode } ! []

        SetDate date ->
            toggleSelectedDate model date

        GetEvents ->
            model ! [ getEvents ]

        Events (Err err) ->
            model ! []

        Events (Ok events) ->
            { model | events = addDistanceToEvents model events } ! [ updateMarkers (extractMarkers events) ]

        GetGeolocation ->
            { model | fetchingLocation = True } ! [ getGeolocation ]

        Location (Err err) ->
            model ! []

        Location (Ok location) ->
            { model
                | userLocation = Just (getCoords location)
                , view = MyDates
                , fetchingLocation = False
            }
                ! []

        InitMap ->
            model ! [ initMap centerAtLondon, setUserLocation model.userLocation ]

        CurrentDate currentDate ->
            { model | currentDate = Just (fromTime currentDate) } ! []

        SetView view ->
            { model | view = view } ! []

        NavigateToResults ->
            { model | view = Results } ! [ getEvents, delay 10 InitMap ]

        GetLatLngFromPostcode ->
            model ! [ getLatLng model ]

        PostcodeToLatLng (Err err) ->
            model ! []

        PostcodeToLatLng (Ok coords) ->
            { model | userLocation = Just coords } ! []

        GoToDates ->
            (model ! [])
                :> update (SetView MyDates)
                :> update GetLatLngFromPostcode
