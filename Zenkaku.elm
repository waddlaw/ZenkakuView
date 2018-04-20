module Main exposing (..)

import Char exposing (toCode)
import Html exposing (Html, div, text, program, textarea, dl, dt, dd, p)
import Html.Attributes exposing (class, placeholder, rows, src, style)
import Html.Events exposing (onInput)
import FileReader
import MimeType
import Maybe.Extra
import Result.Extra

-- モデル
type alias Model =
  { textLen    : Int
  , inDropZone : Bool
  , content    : String
  }

init : ( Model, Cmd Msg )
init =
  ( { textLen    = 0
    , inDropZone = False
    , content    = ""
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
                  [ div ( [ style [ ("width", "100%")
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
                  , p [ class "is-size-3" ]
                      [ text <| "全角文字が" ++ toString model.textLen ++ "文字見つかりました。" ]
                  ]
            ]
      , div [ class "column is-12"
            , style [ ("background-color", "#efefef" ) ]
            ]
            [ p [ ]
                ( if (not <| String.isEmpty model.content) then
                    model.content
                      |> String.lines
                      |> List.map (String.toList >> List.map toHightlight)
                      |> List.intersperse [Html.br [] []]
                      |> List.concat
                  else
                    List.singleton (text "")
                )
            ]
      ]

toHightlight : Char -> Html msg
toHightlight c =
  if isAscii c then
    text <| String.fromChar c
  else
    Html.span [ style [ ("background-color", "hsl(48, 100%, 67%)") ] ]
              [ text (String.fromChar c) ]

dropable : List (Html.Attribute Msg)
dropable = FileReader.dropZone
  { dataFormat = FileReader.Text "utf8"
  , enterMsg   = DropZoneEntered
  , leaveMsg   = DropZoneLeaved
  , filesMsg   = FilesDropped
  }

-- 更新
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( case msg of
      InputText str ->
        { model | textLen = lengthNonAscii str
                , content = str
        }
      DropZoneEntered ->
        { model | inDropZone = True }
      DropZoneLeaved ->
        { model | inDropZone = False }
      FilesDropped files ->
        { model | textLen = files
                          |> List.head
                          |> Maybe.Extra.unwrap 0 (calcNonAscii >> Result.withDefault 0)
                , content = files
                          |> List.head
                          |> Maybe.Extra.unwrap "" (getFileContent >> Result.Extra.extract identity)
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

-- 補助関数
isAscii : Char -> Bool
isAscii c = 0x00 <= toCode c && toCode c <= 0x7f

lengthNonAscii : String -> Int
lengthNonAscii = String.filter (isAscii >> not)
              >> String.length

calcNonAscii : FileReader.File -> Result String Int
calcNonAscii = getFileContent >> Result.map lengthNonAscii

getFileContent : FileReader.File -> Result String String
getFileContent file =
  case file.data of
    Ok data ->
      case (file.dataFormat, MimeType.parseMimeType file.mimeType) of
        (FileReader.DataURL, Just (MimeType.Image _)) -> Err "画像ファイルは対応していません"
        _ -> Ok data
    Err error -> Err ("入力されたファイルが不正です。" ++ toString error.code ++ " " ++ error.name ++ " " ++ error.message)