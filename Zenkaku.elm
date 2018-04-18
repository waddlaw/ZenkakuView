module Main exposing (..)

import Char exposing (toCode)
import Html exposing (Html, div, text, program, textarea, dl, dt, dd, p)
import Html.Attributes exposing (class, placeholder, rows, src, style)
import Html.Events exposing (onInput)
import FileReader
import MimeType

-- モデル
type alias Model =
  { textLen      : Int
  , inDropZone   : Bool
  , content      : String
  }

init : ( Model, Cmd Msg )
init =
  ( { textLen = 0
    , inDropZone = False
    , content = ""
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
      [ div [ class "columns" ]
            [ div [ class "column is-6" ]
                  [ textarea [ class "textarea is-primary"
                            , placeholder "コードをペーストしてください"
                            , rows 20
                            , onInput InputText
                            ]
                            []
                  ]
            , div [ class "column is-6" ]
                  [ p [ class "is-size-1" ]
                      [ text (toString model.textLen) ]
                  , div ( [ style [ ("width", "100%")
                                  , ("height", "430px")
                                  , ("border", "2px dashed #00d1b2")
                                  , ("border-radius", "10px")
                                  , ("display", "flex")
                                  , ("align-items", "center")
                                  , ("justify-content", "center")
                                  ]
                          ] ++ dropable
                        )
                        [ Html.p ( [ class "has-text-centered" ] ++ dropable )
                                [ Html.i [ class "is-size-1 far fa-file-code" ]
                                          []
                                , Html.br [] []
                                , p ( [ style [ ("margin", "1em") ]] ++ dropable )
                                    [ text "ファイルをドロップして分析" ]
                                ]
                        ]
                  ]
            ]
      , div [ class "column is-12" ]
            [ if String.length model.content > 0 then
                div []
                    [text model.content]
              else
                text ""
            ]
      ]

-- dropable : List (Html.Attribute msg)
dropable = FileReader.dropZone
  { dataFormat = FileReader.Text "utf8"
  , enterMsg = DropZoneEntered
  , leaveMsg = DropZoneLeaved
  , filesMsg = FilesDropped
  }

-- 更新
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( case msg of
      InputText str ->
        { model | textLen = String.length (String.filter (not << isAscii) str)
                , content = str
        }
      DropZoneEntered ->
        { model | inDropZone = True }
      DropZoneLeaved ->
        { model | inDropZone = False }
      FilesDropped files ->
        { model | textLen = Maybe.withDefault 0 (List.head (List.map calcZenkaku files))
                , content = Maybe.withDefault "" (Maybe.map getFileContent (List.head files))
        }
  , Cmd.none
  )

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : Program Never Model Msg
main = program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

calcZenkaku : FileReader.File -> Int
calcZenkaku file =
  case file.data of
    Ok data -> String.length (String.filter (not << isAscii) data)
    Err err -> 0

getFileContent : FileReader.File -> String
getFileContent file =
  case file.data of
    Ok data ->
      case (file.dataFormat, MimeType.parseMimeType file.mimeType) of
        (FileReader.DataURL, Just (MimeType.Image _)) -> "画像ファイルは対応していません"
        _ -> data
    Err error -> "入力されたファイルが不正です。" ++ toString error.code ++ " " ++ error.name ++ " " ++ error.message

isAscii : Char -> Bool
isAscii c = 0x00 <= toCode c && toCode c <= 0x7f