module Programs where

import Types
import Syntax
import LIS

{--------- AREA DE PRUEBAS ----------}
-- ejemplos de estado
est1 :: Σ
est1 v = case v of
  "x" -> 1
  "y" -> 2
  "z" -> 3
  _ -> 0

est2 :: Σ
est2 v = case v of
  "x" -> -1
  "y" -> 22
  "z" -> 2
  _ -> 0

-- Ejemplos de expresiones cerradas ("sem e est" o "eval e est" para obtener el resultado)
e1 = (I 13) :+ (I 7)
e2 = (I 5) :* (Op (I 2))
e3 = e1 :/ e2
e4 = e3 :* (Op (I 0))
e5 = ((I 4) :+ (I 25)) :/ e4  -- division por 0
e6 = e2 :* e5  -- usa un valor obtenido de la division por 0

e7 = (B True) :&& (Not (B True))
e8 = Not e7
e9 = e3 :== (I (-2))
e10 = e3 :< e4
e11 = e2 :>= e4
e12 = e1 :<= e1
e13 = e6 :== e6  -- usa un valor obtenido de la division por 0

-- Ejemplos de expresiones no cerradas (reemplazos en las exp. anteriores)
e14 = (I 5) :* (Op (V "y"))
e15 = e2 :== e14
e16 = (e1 :/ e14) :* (Op (V "z"))
e17 = ((V "x") :+ (V "y")) :/ e16
e18 = e14 :< e16
e19 = e14 :* e17
e20 = e19 :== e19

-- Ejemplos de programas ("eval c est" para imprimir el resultado)
c1 = WhileDo ((V "x") :< (I 10)) ((Print (V "x")) :. ("x" := ((V "x") :+ (I 1))))
c2 = WhileDo ((V "y") :< (I 10)) ((Input "x") :. (Print (V "x")) :. (Print (V "y")) :. ("y" := ((V "y") :+ (I 1))))
c3 = (Input "x") :. NewvarIn "x" (I 10) (Print (V "x")) :. (Print (V "x"))
c4 = c1 :. Fail
c5 = c4 :.> c2
c6 = IfThenElse ((V "x") :> (I 0)) (Print (I 1)) (Print (I 0))

-- Ejemplos de programas "utiles"
-- Notar: 1. Las operaciones infijas deben encerrarse en parentesis
-- 2. Los parametros de los operados NO infijos deben encerrarse en parentesis
-- 3. Los operadores unarios NO necesitan parentesis (V, I)

-- Imprimir los pares en un rango ingresado
paresEntre =
  Input "a" :.
  Input "b" :.
  IfThenElse (V "a" :< V "b") (
    ("x" := V "a") :.
    ("y" := V "b")
  ) (
    ("x" := V "b") :.
    ("y" := V "a")
  ) :.
  WhileDo (V "x" :<= V "y") (
    IfThenElse (V "x" :% I 2 :== I 0) (
      Print (V "x")
    ) (
      Skip
    ) :.
    ("x" := (V "x" :+ I 1))
  )

-- Devolver 1 si el numero ingresado es primo (y obligamos a que sea > 0)
esPrimo =
  Input "a" :.
  IfThenElse (V "a" :< I 2) (
    IfThenElse (V "a" :== I 1) (
      Print (I 1)
    ) (
      Fail
    )
  ) (
    NewvarIn "isP" (I 1) (
      NewvarIn "i" (I 2) (
        WhileDo ((V "i" :< V "a") :&& (V "isP" :== I 1)) (
          IfThenElse ((V "a" :% V "i") :== I 0) (
            "isP" := I 0
          ) (
            "i" := (V "i" :+ I 1)
          )
        ) :.
        Print (V "isP")
      )
    )
  )

-- Imprimir los primos en un rango (y obligamos a que los limites sean > 0)
primosEntre =
  Input "a" :.
  Input "b" :.
  IfThenElse ((V "a" :< I 1) :|| (V "b" :< I 1)) (
    Fail
  ) (
    IfThenElse (V "a" :< V "b") (
      ("x" := V "a") :.
      ("y" := V "b")
    ) (
      ("x" := V "b") :.
      ("y" := V "a")
    ) :.
    NewvarIn "curr" (V "x") (
      WhileDo (V "curr" :<= V "y") (
        IfThenElse (V "curr" :== I 1) (
          Skip
        ) (
          NewvarIn "isP" (I 1) (
            NewvarIn "i" (I 2) (
              WhileDo ((V "i" :< V "curr") :&& (V "isP" :== I 1)) (
                IfThenElse ((V "curr" :% V "i") :== I 0) (
                  "isP" := I 0
                ) (
                  "i" := (V "i" :+ I 1)
                )
              ) :.
              IfThenElse (V "isP" :== I 1) (
                Print (V "curr")
              ) (
                Skip
              )
            )
          )
        ) :.
        ("curr" := (V "curr" :+ I 1))
      )
    )
  )

-- MCD y MCM (de 2 numeros > 0)
mcd_mcm =
  Input "a" :.
  Input "b" :.
  IfThenElse ((V "a" :< I 1) :|| (V "b" :< I 1)) (
    Fail
  ) (
    IfThenElse (V "a" :< V "b") (
      "min" := V "a"
    ) (
      "min" := V "b"
    ) :.
    NewvarIn "mcd" (I 1) (
      NewvarIn "mcm" (V "a" :* V "b") (
        NewvarIn "i" (I 2) (
          WhileDo (V "i" :<= V "min") (
            IfThenElse (((V "a" :% V "i") :== I 0) :&& ((V "b" :% V "i") :== I 0)) (
              "mcd" := V "i"
            ) (
              Skip
            ) :.
            ("i" := (V "i" :+ I 1))
          ) :.
          ("mcm" := (V "mcm" :/ V "mcd")) :.
          Print (V "mcd") :.
          Print (V "mcm")
        )
      )
    )
  )

-- Ejemplos dados en la consigna
ej1 =
  WhileDo (V "x" :< I 10) (
    Print (V "x") :.
    ("x" := (V "x" :+ I 1))
  )

eval_ej1 = eval ej1 (\_ -> 0)

ej2 =
  WhileDo (V "y" :< I 10) (
    Input "x" :.
    Print (V "x") :.
    Print (V "y") :.
    ("y" := (V "y" :+ I 1))
  )

eval_ej2 = eval ej2 (\_ -> 0)

ej3 =
  Input "x" :.
  NewvarIn "x" (I 10) (
    Print (V "x")
  ) :.
  Print (V "x")
