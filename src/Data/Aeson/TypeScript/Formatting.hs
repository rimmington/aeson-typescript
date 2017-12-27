{-# LANGUAGE DeriveDataTypeable, QuasiQuotes, OverloadedStrings, TemplateHaskell, RecordWildCards, ScopedTypeVariables, NamedFieldPuns #-}

module Data.Aeson.TypeScript.Formatting where

import Control.Monad
import Control.Monad.Writer
import Control.Monad.Writer.Lazy
import qualified Data.Aeson as A
import Data.Aeson.TypeScript.Types
import Data.Data
import Data.Monoid
import Data.String
import Data.String.Interpolate.IsString
import qualified Data.Text as T
import qualified Data.Text.IO as T
import Data.Typeable
import Language.Haskell.TH
import Language.Haskell.TH.Datatype

formatTSDeclarations = formatTSDeclarations' defaultFormattingOptions

formatTSDeclarations' :: FormattingOptions -> [TSDeclaration] -> String
formatTSDeclarations' options declarations = T.unpack $ T.intercalate "\n\n" (fmap (T.pack . formatTSDeclaration options) declarations)

formatTSDeclaration :: FormattingOptions -> TSDeclaration -> String
formatTSDeclaration (FormattingOptions {numIndentSpaces}) (TSTypeAlternatives name names) = [i|type #{name} = #{alternatives};|]
  where alternatives = T.intercalate " | " (fmap T.pack names)
formatTSDeclaration (FormattingOptions {numIndentSpaces}) (TSInterfaceDeclaration interfaceName members) = [i|interface #{interfaceName} {
#{lines}
}|] where lines = T.intercalate "\n" $ fmap T.pack [(replicate numIndentSpaces ' ') <> formatTSField member <> ";"| member <- members]

formatTSField :: TSField -> String
formatTSField (TSField optional name typ) = [i|#{name}#{if optional then "?" else ""}: #{typ}|]