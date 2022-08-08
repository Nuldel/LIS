{-# LANGUAGE GADTs, TypeSynonymInstances, FlexibleInstances #-}
module LIS where

import Data.Maybe
import Syntax
import Types

{- Funciones semánticas -}
class DomSem dom where
   sem :: Expr dom -> Σ -> dom

instance DomSem MInt where
   sem e σ = case e of
     I x -> Just x
     V v -> Just (σ v)
     Op e1 -> computeMaybe1 (sem e1 σ) (*(-1))
     e1 :+ e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (+)
     e1 :- e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (-)
     e1 :* e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (*)
     e1 :/ e2 -> if isJust r1 && isJust r2 && fromJust r2 /= 0 then Just (div (fromJust r1) (fromJust r2)) else Nothing
       where r1 = sem e1 σ
             r2 = sem e2 σ
     e1 :% e2 -> if isJust r1 && isJust r2 && fromJust r2 /= 0 then Just (mod (fromJust r1) (fromJust r2)) else Nothing
       where r1 = sem e1 σ
             r2 = sem e2 σ

instance DomSem MBool where
   sem e σ = case e of
     B b -> Just b
     Not e1 -> computeMaybe1 (sem e1 σ) not
     e1 :&& e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (&&)
     e1 :|| e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (||)
     e1 :== e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (==)
     e1 :< e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (<)
     e1 :> e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (>)
     e1 :<= e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (<=)
     e1 :>= e2 -> computeMaybe2 (sem e1 σ) (sem e2 σ) (>=)

instance DomSem Ω where
  sem e σ = case e of
    Skip -> Normal σ
    Fail -> Abort σ
    v := e1 -> (sem e1 σ, σ) >>== (\x est1 -> Normal (update est1 v x))
    IfThenElse b c1 c2 -> (sem b σ, σ) >>== (\b1 est1 -> if b1 then sem c1 est1 else sem c2 est1)
    c1 :. c2 -> (sem c2) *. (sem c1 σ)
    c1 :.> c2 -> (sem c2) +. (sem c1 σ)
    Print e1 -> (sem e1 σ, σ) >>== (\x est1 -> Out (x, Normal est1))
    NewvarIn v e1 c1 -> (\new -> update new v (σ v)) †. ((sem e1 σ, σ) >>== (\x est1 -> sem c1 (update est1 v x)))
    Input v -> In (\x -> Normal (update σ v x))
    WhileDo b c1 -> (fix (f :: F)) σ where f g est1 = (sem b est1, est1) >>== (\b1 est2 -> if b1 then g *. (sem c1 est2) else Normal est2)

-- evaluacion de programas (para ingresar e imprimir valores en pantalla)
class Eval dom where
  eval :: Expr dom -> Σ -> IO ()

instance Eval MInt where
  eval e = putStrLn . show . sem e

instance Eval MBool where
  eval e = putStrLn . show . sem e

instance Eval Ω where
  eval e = unrollOmega . sem e
    where unrollOmega :: Ω -> IO ()
          unrollOmega (Normal _)   = return ()
          unrollOmega (Abort _)    = putStrLn "Abort"
          unrollOmega (Out (n, ω)) = putStrLn (show n) >> unrollOmega ω
          unrollOmega (In f)       = putStrLn "Awaiting Input..." >> getLine >>= unrollOmega . f . read
