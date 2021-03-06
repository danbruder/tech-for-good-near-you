module State exposing (..)

import Config exposing (searchRadii)
import Data.Dates exposing (getCurrentDate, handleSelectedDate, setCurrentDate)
import Data.Events exposing (..)
import Data.Location.Postcode exposing (..)
import Data.Maps exposing (..)
import Data.Navigation exposing (handleResetMobileNav, handleToggleTopNavbar)
import Data.Ports exposing (..)
import Helpers.Window exposing (getWindowSize, handleScrollEventsToTop, scrollEventContainer)
import RemoteData exposing (RemoteData(..))
import Request.CustomEvents exposing (getCustomEvents, handleReceiveCustomEvents)
import Request.MeetupEvents exposing (getMeetupEvents, handleReceiveMeetupEvents)
import Request.Postcode exposing (handleGetLatLngFromPostcode, handleRecievePostcodeLatLng)
import Types exposing (..)
import Update.Extra exposing (addCmd, andThen)
import Window exposing (resizes)


init : ( Model, Cmd Msg )
init =
    initialModel
        ! [ getCurrentDate
          , initMapAtLondon initialModel
          , getMeetupEvents
          , getCustomEvents
          , getWindowSize
          ]


initialModel : Model
initialModel =
    { postcode = NotEntered
    , selectedDate = All
    , today = Nothing
    , meetupEvents = Loading
    , customEvents = Loading
    , userLocation = NotAsked
    , searchRadius = searchRadii.national
    , topNavOpen = False
    , bottomNavOpen = False
    , mobileDateOptionsVisible = False
    , window = { width = 0, height = 0 }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdatePostcode postcode ->
            handleUpdatePostcode postcode model ! []

        ClearUserLocation ->
            (handleClearUserLocation model ! [ clearUserLocation ])
                |> andThen update FilteredMarkers

        SetDateRange date ->
            (handleSelectedDate date model ! [])
                |> andThen update FilteredMarkers
                |> addCmd (handleScrollEventsToTop model)

        CurrentDate date ->
            setCurrentDate date model ! []

        ReceiveMeetupEvents events ->
            (handleReceiveMeetupEvents events model ! []) |> andThen update UpdateMap

        ReceiveCustomEvents events ->
            (handleReceiveCustomEvents events model ! []) |> andThen update UpdateMap

        FetchEvents ->
            handleFetchEvents model ! [ getMeetupEvents, getCustomEvents ]

        FetchEventsForPostcode ->
            { model | searchRadius = searchRadii.local } ! [ handleGetLatLngFromPostcode model ]

        RecievePostcodeLatLng (Success coords) ->
            (handleRecievePostcodeLatLng (Success coords) model ! [ updateUserLocation coords ])
                |> andThen update FetchEvents

        RecievePostcodeLatLng remoteData ->
            handleRecievePostcodeLatLng remoteData model ! []

        MobileDateVisible bool ->
            { model | mobileDateOptionsVisible = bool } ! []

        UpdateMap ->
            model ! [ updateMap ]

        CenterEvent marker ->
            model ! [ centerEvent marker ]

        FitBounds ->
            model ! [ fitBounds ]

        ToggleTopNavbar ->
            handleToggleTopNavbar model ! []

        BottomNavOpen bool ->
            { model | bottomNavOpen = bool } ! [ refreshMapSize ]

        ResetMobileNav ->
            handleResetMobileNav model ! [ refreshMapSize ]

        FilteredMarkers ->
            model ! [ updateFilteredMarkers model ]

        CenterMapOnUser ->
            model ! [ centerMapOnUser ]

        RefreshMapSize ->
            model ! [ resizeMap ]

        WindowSize size ->
            { model | window = size } ! []

        ScrollToEvent offset ->
            model ! [ scrollEventContainer offset model ]

        Scroll _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ resizes WindowSize
        , scrollToEvent ScrollToEvent
        ]
