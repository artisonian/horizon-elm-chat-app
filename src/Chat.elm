import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)


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
  ( Model userId ""
    [ Message "1" "Hello world"
    , Message "1" "Goodbye world"
    , Message "2" "O hai"
    , Message "1" "K thx bye"
    ]
  , Cmd.none
  )


-- UPDATE


type Msg
  = Input String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input newInput ->
      ( { model | input = newInput }
      , Cmd.none
      )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ ul [ class "message-list" ] (List.map chatMessage model.messages)
    , input [ type' "text", class "new-message-field", autofocus True, onInput Input ] []
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
