module Types where

-- tipos basicos. una capa de abstracccion (Maybe) para controlar errores
type Var   = String
type Σ     = Var -> Int

type MInt  = Maybe Int
type MBool = Maybe Bool
data Ω = Normal Σ | Abort Σ | Out (Int, Ω) | In (Int -> Ω)

-- Un alias util para usar en el while
type F = (Σ -> Ω) -> (Σ -> Ω)
