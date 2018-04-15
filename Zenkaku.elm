module Main exposing (..)

import Html exposing (Html, button, div, text, program, textarea)
import Html.Events exposing (onInput)
import FileReader
import Html.Attributes
import MimeType
import Char exposing (toCode)

-- モデル
type alias Model =
  { length : Int
  , inDropZone : Bool
  , droppedFiles : List FileReader.File
  }

init : ( Model, Cmd Msg )
init =
  ( { length = 0
    , inDropZone = False
    , droppedFiles = []
    }
  , Cmd.none
  )

-- メッセージ
type Msg
  = InputText String
  | DropZoneEntered
  | DropZoneLeaved
  | FilesDropped (List FileReader.File)

-- ビュー
view : Model -> Html Msg
view model =
    div []
        [ textarea [ onInput InputText ] []
        , text (toString model.length)
        , Html.div
            (FileReader.dropZone
                    { dataFormat = FileReader.Text "utf8"
                    , enterMsg = DropZoneEntered
                    , leaveMsg = DropZoneLeaved
                    , filesMsg = FilesDropped
                    }
            )
            [ Html.text "Drop files here" ]
        , if List.length model.droppedFiles > 0 then
            Html.div [] (List.map viewFile model.droppedFiles)
          else
            Html.text ""
        ]

-- 更新
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( case msg of
      InputText str ->
        { model | length = String.length (String.filter (not << isAscii) str) }
      DropZoneEntered ->
        { model | inDropZone = True }
      DropZoneLeaved ->
        { model | inDropZone = False }
      FilesDropped files ->
        { model | length = Maybe.withDefault 5555 (List.head (List.map calcZenkaku files)), droppedFiles = files }
  , Cmd.none
  )

-- サブスクリプション(購読)
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- MAIN
main : Program Never Model Msg
main = program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- helper
calcZenkaku : FileReader.File -> Int
calcZenkaku file =
  case file.data of
    Ok data -> String.length (String.filter (not << isAscii) data)
    Err err -> 9999

viewFile : FileReader.File -> Html Msg
viewFile file =
    Html.div []
        [ Html.dl []
            [ Html.dt [] [ Html.text "Data" ]
            , Html.dd []
                (case file.data of
                    Ok data ->
                        case ( file.dataFormat, MimeType.parseMimeType file.mimeType ) of
                            ( FileReader.DataURL, Just (MimeType.Image _) ) ->
                                [ Html.img [ Html.Attributes.src data ] [] ]

                            _ ->
                                [ Html.text data ]

                    Err error ->
                        [ Html.text ("Error: " ++ toString error.code ++ " " ++ error.name ++ " " ++ error.message) ]
                )
            ]
        ]


isAscii : Char -> Bool
isAscii c = 0x00 <= toCode c && toCode c <= 0x7f