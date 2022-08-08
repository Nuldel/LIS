# Lenguaje imperativo simple (LIS) con Haskell
## Descripción
La implementación de un lenguaje imperativo completo 100% en Haskell (un lenguaje funcional). La idea es explorar las relaciones fundamentales entre ambos paradigmas (funcional e imperativo) y la dificutad en reducir los significados de los programas a sus componentes básicos, haciendo uso intensivo de la *Teoría de Lenguajes* de programación. Las capacidades del lenguaje son las siguientes:
* Un **estado**; como los lenguajes funcionales no tienen estado, se emuló el mismo con una función que lleva nombres de variables (*String*) a valores enteros. Este es un estado simple que sólo guarda números (puede extenderse).
* Operaciones entre enteros: declaración, suma, resta, producto, divisón, opuesto, módulo (ver especificaciones a continuación).
* Operaciones booleanas (True/False): AND, OR, ==, >, >=, <, <=, NOT.
* Estructuras de control: asignación, concatenación (como el **;** de C/C++), SKIP, IF, WHILE, INPUT, PRINT.
* Manejo de errores: FAIL, CATCH.

## Requerimentos
Nada más y nada menos que Haskell.

## Utilización
La base de un lenguaje funcional es que en lugar de procesar instrucciones en orden, toma un valor y devuelve un resultado acorde. En ese caso, le decimos a Haskell que la evaluación de un programa es exactamente eso: la devolución de un valor. En **LIS.hs** está definida la estructura *semántica** del lenguaje, haciendo uso del alto nivel de abstracción que caracteriza a Haskell. La función global para evaluar es:

```
eval (body) (state)
```
donde ambos *body* y *state* son requeridos. El *body* es cualquier programa escrito exactamente como indican las especificaciones a continuación, y el *state* es un estado, es decir, una función de variables a enteros (en Haskell es simple definir funciones rápidas y pasarlas como argumentos a otras funciones). Un programa puede devolver un entero directamente (si es un cálculo) o un valor True/False (si es la comprobación de un predicado) o, si es hay estructuras de control presentes, alguna de las salidas posibles del procesamiento del programa:
* Terminación normal (no hay nada que reportar).
* Abort (hubo algún error semántico, pero NO de sintaxis (ej.: división por 0)).
* Impresión de valores en pantalla, si hay declaraciones PRINT, seguida por alguna de las opciones anteriores.
* Input necesario: el programa se pone en pausa hasta que el usuario ingrese el valor de una variable que necesita.

Esto puede considerarse similar a la interfaz de **Python**, en la cual se pueden hacer cálculos básicos o ejecutar un script, pero con variables iniciales definidas. Si las variables iniciales no importan (se pedirá input durante la ejecución), se pueden asignar todas a un valor por defecto, como cero:

```
eval (body) (\_ -> 0)
```

Para llegar a esta instancia, la ejecución es la usual para Haskell:

```
$ ghci LIS.hs
*Main> eval (body) (state)
```

donde en general el *body* será algún programa guardado en una variable.
Para usar un entorno de programas de ejemplo ya construidos, cargar en cambio **Programs.hs**, que ya importa el lenguaje entero (para que sus expresiones tengan sentido).

## Especificaciones
Un programa es una sucesión de instrucciones con (:.) (concatenación) de por medio. Puede usarse una nueva línea para cada instrucción e indentación por cuestiones de legibilidad, pero el evaluador no los toma en cuenta. Para cada operador hay un símbolo (distinto al de Haskell para no causar conflictos) o una palabra clave; en general, los símbolos son operados *infijos*, lo cual quiere decir que se pueden usar entre cada par de operandos, aunque esto no es obligatorio. Por ejemplo:
```
I 2 :+ I 3
```
es lo mismo que
```
(:+) (I 2) (I 3)
```

¿Qué pasa con los paréntesis? Además de ser necesarios para usar operadores infijos a la cabeza (sintaxis de Haskell), se usan paréntesis para:
* encerrar operaciones infijas, aislándolas del resto del programa, y
* encerrar los parámetros de operaciones no infijas (o bien que están siendo usadas con modalidad no infija).

Los paréntesis NO son necesarios en operaciones unarias (parámetro único)

A continuación, la sintexis de cada operador (constructor); los que llevan paréntesis son naturalmente infijos, aunque los parámetros se muestren a la derecha.
* Manejo de enteros
  * Usar entero: **I** [*int*] (no se usan enteros sin este constructor)
  * Usar variable: **V** [*string*] (no se usan variables sin este constructor)
  * Cambiar signo: **Op** [arg]
  * Suma: **(:+)** [arg1] [arg2]
  * Resta: **(:-)** [arg1] [arg2]
  * Producto: **(:*)** [arg1] [arg2]
  * división: **(:/)** [arg1] [arg2]
  * Módulo (resto): **(:%)** [arg1] [arg2]
* Manejo de predicados
  * Usar bool: **B** [*bool*]
  * Negar: **Not** [arg]
  * Conjunción: **(:&&)** [arg1] [arg2]
  * Disyunción: **(:||)** [arg1] [arg2]
  * Comparación: **(:==)** [arg1] [arg2]
  * Menor: **(:<)** [arg1] [arg2]
  * Mayor: **(:>)** [arg1] [arg2]
  * Menor/igual: **(:<=)** [arg1] [arg2]
  * Mayor/igual: **(:>=)** [arg1] [arg2]
* Estructuras de control
  * Saltar instrucción: **Skip**
  * Asignación de variable: **(:=)** [var (*string*)] [arg]
  * Concatenación: **(:.)** [instrución] [resto del programa]
  * Condicional: **IfThenElse** [Condición] [guarda1] [guarda2]
  * declaración local: **NewvarIn** [var (*string*)] [arg] [programa donde aplicar]
  * Ciclo: **WhileDo** [condición] [guarda]
  * Levantar error: **Fail**
  * Atrapar error: **(:.>)** [programa a probar] [programa para manejar error]
  * Imprimir en pantalla: **Print** [arg]
  * Pedir valor para una variable: **Input** [var (*string*)]

Los errores se pueden manejar manualmente, pero también surgen de una semántica incorrecta, no sólo por cuestiones aritméticas como división por cero, sino especialmente por conflictos de tipos. Notar que los operadores de enteros reciben expresiones que deberían a la larga reducirse a enteros; análogamente con los operadores de predicados (booleanos), mientras que las estructuras de control manejan programas de cualquier tipo, excepto cuando se piden variables concretas o guardas (los cuales son predicados).

A continuación, un ejemplo medianamente sofisticado de lo que se puede hacer con el lenguaje (sacado de **Programs.hs**), en donde se usaron múltiples líneas con indentación. Esto se puede copiar y pegar para funcionar directamente con la función evaluadora (cualquier estado inicial sirve).

```
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
```
