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


init : Flags -> (Model, Cmd Msg)
init {userId} =
  ( Model userId "" []
  , Cmd.none
  )


-- UPDATE


type Msg
  = Input String
  | SendOnEnter Int
  | Fetch (List Message)


port save : Message -> Cmd msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input newInput ->
      ( { model | input = newInput }
      , Cmd.none
      )

    SendOnEnter code ->
      if code == 13 then
        let
          message =
            Message model.userId model.input
        in
          ( { model | input = "" }
          , save message
          )
      else
        (model, Cmd.none)

    Fetch messages ->
      ( { model | messages = messages }
      , Cmd.none
      )


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
      , onInput Input
      , onKeyPress SendOnEnter
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


onKeyPress : (Int -> msg) -> Attribute msg
onKeyPress tagger =
  on "keypress" (Json.map tagger keyCode)
