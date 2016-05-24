port module Main exposing (..)


import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json


main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Model =
  { userId : String
  , input : String
  , messages : List Message
  }


type alias Message =
  { authorId : String
  , message : String
  }


type alias Flags =
  { userId : String
  }


emptyModel : Model
emptyModel =
  { userId = ""
  , input = ""
  , messages = []
  }


init : Flags -> (Model, Cmd Msg)
init {userId} =
  { emptyModel
    | userId = userId
  }
    ! []


-- UPDATE


type Msg
  = NoOp
  | UpdateInput String
  | Save
  | Fetch (List Message)


port save : Message -> Cmd msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    UpdateInput newInput ->
      { model | input = newInput }
        ! []

    Save ->
      { model | input = "" }
        ! [ save (Message model.userId model.input) ]

    Fetch messages ->
      { model | messages = messages }
        ! []


-- SUBSCRIPTIONS


port fromHorizon : (List Message -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
  fromHorizon Fetch


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ ul [ class "message-list" ] (List.map chatMessage model.messages)
    , input
      [ type' "text"
      , class "new-message-field"
      , autofocus True
      , value model.input
      , onInput UpdateInput
      , onEnter NoOp Save
      ] []
    ]


chatMessage : Message -> Html Msg
chatMessage {authorId, message} =
  let
    avatarUrl =
      "http://api.adorable.io/avatars/50/" ++ authorId ++ ".png"
  in
    li [ class "message" ]
      [ img [ class "avatar", src avatarUrl ] []
      , span [ class "message-text" ] [ text message ]
      ]


onEnter : msg -> msg -> Attribute msg
onEnter fail success =
  let
    tagger code =
      if code == 13 then success else fail
  in
    on "keyup" (Json.map tagger keyCode)
