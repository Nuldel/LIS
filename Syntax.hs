{-# LANGUAGE GADTs #-}
module Syntax where

import Data.Maybe
import Types

-- funcion continua a la cual aplicar el t. del punto fijo
--         ∞
-- fix f = ⊔ fⁱ ⊥
--        i=0
fix :: (a -> a) -> a
fix f = f (fix f)

-- funciones auxiliares: aplicar funciones básicas a los valores Maybe
computeMaybe1 :: Maybe a -> (a -> b) -> Maybe b
computeMaybe1 Nothing f = Nothing
computeMaybe1 (Just x) f = Just (f x)

computeMaybe2 :: Maybe a -> Maybe a -> (a -> a -> b) -> Maybe b
computeMaybe2 Nothing _ f = Nothing
computeMaybe2 _ Nothing f = Nothing
computeMaybe2 (Just x) (Just y) f = Just (f x y)

-- Propagacion de error
(>>==) :: (Maybe a, Σ) -> (a -> Σ -> Ω) -> Ω
(>>==) (Nothing, σ) _ = Abort σ
(>>==) (Just n, σ)  f = f n σ

-- Funciones de transferencia de control
(*.) :: (Σ -> Ω) -> Ω -> Ω
(*.) f (Normal σ)  = f σ
(*.) _ (Abort σ)   = Abort σ
(*.) f (Out (n,ω)) = Out (n, f *. ω)
(*.) f (In g)      = In ((f *.) . g)

(†.) :: (Σ -> Σ) -> Ω -> Ω
(†.) f (Normal σ)  = Normal $ f σ
(†.) f (Abort σ)   = Abort $ f σ
(†.) f (Out (n,ω)) = Out (n, f †. ω)
(†.) f (In g)      = In ((f †.) . g)

(+.) :: (Σ -> Ω) -> Ω -> Ω
(+.) _ (Normal σ)  = Normal σ
(+.) f (Abort σ)   = f σ
(+.) f (Out (n,ω)) = Out (n, f +. ω)
(+.) f (In g)      = In ((f +.) . g)

-- Funcion de reemplazo de estado
update :: Σ -> Var -> Int -> Σ
update σ v n v' = if v == v' then n else σ v'

{- Sintaxis -}
data Expr a where
  I       :: Int        -> Expr MInt
  V       :: Var        -> Expr MInt
  Op         :: Expr MInt  -> Expr MInt
  (:+)       :: Expr MInt  -> Expr MInt  -> Expr MInt
  (:-)       :: Expr MInt  -> Expr MInt  -> Expr MInt
  (:*)       :: Expr MInt  -> Expr MInt  -> Expr MInt
  (:/)       :: Expr MInt  -> Expr MInt  -> Expr MInt
  (:%)       :: Expr MInt  -> Expr MInt  -> Expr MInt

  B      :: Bool       -> Expr MBool
  Not        :: Expr MBool -> Expr MBool
  (:&&)      :: Expr MBool -> Expr MBool -> Expr MBool
  (:||)      :: Expr MBool -> Expr MBool -> Expr MBool
  (:==)      :: Expr MInt  -> Expr MInt  -> Expr MBool
  (:<)       :: Expr MInt  -> Expr MInt  -> Expr MBool
  (:>)       :: Expr MInt  -> Expr MInt  -> Expr MBool
  (:<=)      :: Expr MInt  -> Expr MInt  -> Expr MBool
  (:>=)      :: Expr MInt  -> Expr MInt  -> Expr MBool

  Skip       :: Expr Ω
  (:=)       :: Var        -> Expr MInt  -> Expr Ω  -- Asignacion
  (:.)       :: Expr Ω     -> Expr Ω     -> Expr Ω  -- Concatenacion
  IfThenElse :: Expr MBool -> Expr Ω     -> Expr Ω -> Expr Ω
  NewvarIn   :: Var        -> Expr MInt  -> Expr Ω -> Expr Ω
  WhileDo    :: Expr MBool -> Expr Ω     -> Expr Ω
  Fail       :: Expr Ω
  (:.>)      :: Expr Ω     -> Expr Ω     -> Expr Ω  -- catch (arg 1) with (arg 2)
  Print      :: Expr MInt  -> Expr Ω
  Input      :: Var        -> Expr Ω
