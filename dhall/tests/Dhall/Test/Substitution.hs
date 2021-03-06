{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Dhall.Test.Substitution where

import Data.Void (Void)
import Dhall.Core (Expr(BoolLit, Var))
import Dhall.Src (Src)

import qualified Dhall
import qualified Dhall.Map
import qualified Lens.Family   as Lens

data Result = Failure Integer | Success String
    deriving (Eq, Dhall.Generic, Show)

instance Dhall.FromDhall Result

substituteResult :: FilePath -> IO Result
substituteResult fp = let
    evaluateSettings = Lens.over Dhall.substitutions (Dhall.Map.insert "Result" resultType) Dhall.defaultEvaluateSettings
    in Dhall.inputFileWithSettings evaluateSettings resultDecoder fp

resultDecoder :: Dhall.Decoder Result
resultDecoder = Dhall.auto

resultType :: Expr Src Void
resultType = Dhall.expected resultDecoder

substituteFoo :: FilePath -> IO Bool
substituteFoo fp = let
    evaluateSettings = Lens.set Dhall.substitutions (Dhall.Map.fromList [("Foo", Var "Bar"), ("Bar", BoolLit True)]) Dhall.defaultEvaluateSettings
    in Dhall.inputFileWithSettings evaluateSettings Dhall.auto fp
