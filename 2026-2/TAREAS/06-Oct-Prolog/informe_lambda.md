# Operacion Lambda — Informe de la actividad

**Alumno:** Jose Fernando Martinez Valdez  
**Matricula:** 21120231  
**Entorno utilizado:** Kali Linux y GNU CLISP  
**Archivo del programa:** `mision_lambda.lisp`

## Objetivo

Practicar el manejo de listas en Common Lisp: consultar datos con `car` y `cdr`, transformar listas con `mapcar`, crear funciones con `lambda`, filtrar registros y construir funciones que devuelven otras funciones.

## Preparacion del entorno

Se creo la carpeta `OperacionLambda` y se edito el programa con Nano. Al inicio del archivo se colocaron los registros de los seis agentes, el alfabeto, el mensaje cifrado y los bonos.

Cada registro sigue este orden:

```lisp
(nombre edad nivel base puntos)
```

Para cargar el programa se utilizo:

```lisp
(load "/home/kali/OperacionLambda/mision_lambda.lisp")
```

**Nota sobre las evidencias:** las misiones 1 y 2 y las pruebas de descifrado de la mision 3 fueron comprobadas en las capturas compartidas. Tambien se comprobo el cifrado de la palabra TRAIDOR. La comprobacion inversa del mensaje completo y las misiones 4, 5 y 6 tienen codigo preparado, pero no se proporcionaron sus salidas de CLISP. En esos apartados se indican resultados esperados, no resultados ejecutados. El archivo completo se reviso en su estructura, pero no se ejecuto con CLISP durante su generacion.

## Mision 1 — El expediente desordenado

### Lo que se realizo

Primero se consulto `*agentes*` para comprobar que los datos estaban cargados. Despues se probaron `car` y `cdr`:

```lisp
(car *agentes*)
; (ANA 28 3 MORELIA 120)

(cdr *agentes*)
; Lista de registros desde BETO hasta FAUSTO.
```

Se observo que `car` devuelve el primer elemento y `cdr` devuelve la lista restante, sin modificar la lista original. Para resolver las expresiones se leyeron los parentesis de adentro hacia afuera.

### Tabla de resultados

La columna de resultado previsto resume el analisis guiado. No sustituye las predicciones personales que debian anotarse antes de ejecutar.

| Inciso | Expresion | Resultado previsto en la guia | Resultado observado en CLISP |
|---|---|---|---|
| a | `(car (cdr (car *agentes*)))` | `28` | `28` |
| b | `(car (car (cdr *agentes*)))` | `BETO` | `BETO` |
| c | `(cdr (car (cdr (cdr *agentes*))))` | `(22 1 MORELIA 45)` | `(22 1 MORELIA 45)` |
| d | `(car (cdr (cdr (cdr (car (cdr (cdr (cdr *agentes*))))))))` | `ZAMORA` | `ZAMORA` |
| e | `(caddr (cadr *agentes*))` | `5` | `5` |
| f | `(car (cdr (cdr (car (cdr (cdr (cdr (cdr *agentes*))))))))` | `2` | `2` |

**Notas:** a obtiene la edad de Ana; b, el nombre de Beto; c, los datos de Carla sin su nombre; d, la base de Diego; e, el nivel de Beto; f, el nivel de Elena. El inciso e aparece abreviado en el enunciado; su equivalente usando solo `car` y `cdr` es:

```lisp
(car (cdr (cdr (car (cdr *agentes*)))))
```

### Funciones de acceso

Se crearon cinco funciones para no repetir expresiones largas al consultar campos:

```lisp
(defun nombre (ag) (car ag))
(defun edad (ag) (car (cdr ag)))
(defun nivel (ag) (car (cdr (cdr ag))))
(defun base (ag) (car (cdr (cdr (cdr ag)))))
(defun puntos (ag) (car (cdr (cdr (cdr (cdr ag))))))
```

Se probaron con el registro de Ana:

| Prueba | Salida observada |
|---|---|
| `(nombre (car *agentes*))` | `ANA` |
| `(edad (car *agentes*))` | `28` |
| `(nivel (car *agentes*))` | `3` |
| `(base (car *agentes*))` | `MORELIA` |
| `(puntos (car *agentes*))` | `120` |

### Puntos de Elena

```lisp
(puntos (car (cdr (cdr (cdr (cdr *agentes*))))))
; Salida observada: 90
```

Los cuatro `cdr` saltan los primeros cuatro registros; `car` selecciona a Elena y `puntos` extrae su quinto campo. No se escribio el valor de sus puntos en la consulta.

### Registro incompleto

```lisp
(car (cdr '(ana)))
; Salida observada: NIL
```

No es un error: al quitar ANA queda una lista vacia y `car` de `NIL` devuelve `NIL`. Esto puede ocultar que falta un dato. Si despues se utiliza ese resultado como numero, una operacion aritmetica puede fallar.

### Dificultades y correcciones

- En el inciso b se copio una expresion con un parentesis de cierre adicional desde la guia. CLISP devolvio BETO y luego mostro un error de lectura. Se corrigio quitando el parentesis sobrante y se salio de la depuracion con la opcion de reinicio indicada por CLISP. Fue un error de escritura, no una prediccion incorrecta.
- El inciso f se ejecuto dos veces; posteriormente se ejecuto el inciso e que faltaba.
- Al abrir otra sesion de CLISP desde la carpeta personal, `(load "mision_lambda.lisp")` no encontro el archivo. Se soluciono usando la ruta completa a `OperacionLambda`.
- Las capturas no muestran predicciones personales distintas de los resultados; no se inventan errores de prediccion.

## Mision 2 — El pase de lista

### Prueba 1: obtener todos los nombres

```lisp
(defun pase-de-lista (agentes)
  (mapcar #'nombre agentes))

(pase-de-lista *agentes*)
```

**Salida observada:**

```lisp
(ANA BETO CARLA DIEGO ELENA FAUSTO)
```

`mapcar` aplico la funcion `nombre` a cada registro y reunio los resultados en una lista.

### Prueba 2: nombre y nivel

```lisp
(defun nombre-y-nivel (agentes)
  (mapcar (lambda (ag)
            (cons (nombre ag) (nivel ag)))
          agentes))

(nombre-y-nivel *agentes*)
```

**Salida observada:**

```lisp
((ANA . 3) (BETO . 5) (CARLA . 1)
 (DIEGO . 4) (ELENA . 2) (FAUSTO . 5))
```

Se uso una `lambda` para trabajar con cada agente. `cons` unio el nombre y el nivel en un par punteado. El punto separa los dos componentes; no es un decimal.

### Prueba 3: cumpleanios

```lisp
(defun cumpleanios (agentes)
  (mapcar (lambda (ag)
            (list (nombre ag) (+ (edad ag) 1)))
          agentes))

(cumpleanios *agentes*)
```

**Salida observada:**

```lisp
((ANA 29) (BETO 36) (CARLA 23)
 (DIEGO 42) (ELENA 31) (FAUSTO 27))
```

Se sumo uno a cada edad y se construyeron listas nuevas con `list`. Inmediatamente despues se consulto la edad original de Ana:

```lisp
(edad (car *agentes*))
; Salida observada: 28
```

La consulta confirmo que la edad original de Ana permanecio igual. La funcion no contiene instrucciones que modifiquen los registros.

### Prueba 4: aplicar bonos

```lisp
(defun aplicar-bonos (agentes bonos)
  (mapcar (lambda (ag bono)
            (+ (puntos ag) bono))
          agentes bonos))

(aplicar-bonos *agentes* *bonos*)
```

**Salida observada:**

```lisp
(130 340 50 230 105 400)
```

| Agente | Puntos | Bono | Resultado |
|---|---:|---:|---:|
| Ana | 120 | 10 | 130 |
| Beto | 340 | 0 | 340 |
| Carla | 45 | 5 | 50 |
| Diego | 210 | 20 | 230 |
| Elena | 90 | 15 | 105 |
| Fausto | 400 | 0 | 400 |

`mapcar` tomo un elemento de cada lista por turno. Por eso la `lambda` tiene dos parametros: un registro y un bono.

### Por que se escribe #'car

`#'car` referencia la funcion `car` para pasarla como argumento. Si se escribe solamente `car` en ese lugar, Lisp intenta obtener el valor de una variable llamada CAR. En el programa se uso `#'nombre` con la misma finalidad.

**Nota:** con una lista, `mapcar` devuelve un resultado por elemento. Con varias listas, termina cuando se agota la mas corta.

## Mision 3 — El mensaje interceptado

### Prueba 1: descifrar un codigo

```lisp
(defun descifrar-codigo (n)
  (nth (mod (- n 3) 26) *alfabeto*))
```

Se resto el desplazamiento de tres posiciones y se uso `mod` para mantener el indice entre 0 y 25. `nth` obtuvo la letra; en esta mision si esta permitido.

| Prueba | Salida observada | Explicacion |
|---|---|---|
| `(descifrar-codigo 22)` | `T` | 22 menos 3 da 19, posicion de T. |
| `(descifrar-codigo 3)` | `A` | 3 menos 3 da 0, posicion de A. |
| `(descifrar-codigo 1)` | `Y` | El modulo convierte -2 en 24, posicion de Y. |

### Prueba 2: descifrar una palabra

```lisp
(defun descifrar-palabra (palabra)
  (mapcar #'descifrar-codigo palabra))

(descifrar-palabra (car *interceptado*))
```

**Salida observada:**

```lisp
(T R A I D O R)
```

### Prueba 3: descifrar el mensaje completo

```lisp
(defun descifrar-mensaje (mensaje)
  (mapcar #'descifrar-palabra mensaje))

(descifrar-mensaje *interceptado*)
```

**Salida observada:**

```lisp
((T R A I D O R) (N I V E L) (C I N C O)
 (F U E R A) (D E) (M O R E L I A))
```

**Mensaje:** TRAIDOR NIVEL CINCO FUERA DE MORELIA.

Hay dos niveles de listas: el mensaje contiene palabras y cada palabra contiene numeros. Una funcion trabaja con las palabras y la otra con sus numeros.

### Prueba 4: dos lambdas anidadas

```lisp
(defun descifrar-mensaje-lambda (mensaje)
  (mapcar (lambda (palabra)
            (mapcar (lambda (n)
                      (nth (mod (- n 3) 26) *alfabeto*))
                    palabra))
          mensaje))
```

La version independiente en una sola expresion es:

```lisp
(mapcar (lambda (palabra)
          (mapcar (lambda (n)
                    (nth (mod (- n 3) 26) *alfabeto*))
                  palabra))
        *interceptado*)
```

Se compararon las dos funciones:

```lisp
(equal (descifrar-mensaje *interceptado*)
       (descifrar-mensaje-lambda *interceptado*))
; Salida observada: T
```

`T` significa que las listas obtenidas son iguales. La version anidada hace el calculo directamente, sin llamar a las funciones auxiliares de descifrado.

### Extra: volver a cifrar

```lisp
(defun cifrar-palabra (palabra)
  (mapcar (lambda (letra)
            (mod (+ (position letra *alfabeto*) 3) 26))
          palabra))

(cifrar-palabra '(t r a i d o r))
```

**Salida observada:**

```lisp
(22 20 3 11 6 17 20)
```

`position` obtiene la posicion de la letra; despues se suma tres y se aplica modulo 26.

**Comprobacion del mensaje completo pendiente de evidencia:**

```lisp
(equal
  (mapcar #'cifrar-palabra (descifrar-mensaje *interceptado*))
  *interceptado*)
```

Resultado esperado: `T`. Tambien puede ejecutarse `(comprobar-cifrado)` en el archivo completo.

## Mision 4 — El traidor

**Estado:** funciones incluidas en el archivo completo; resultados siguientes pendientes de comprobar en CLISP.

### Prueba 1: filtrar sospechosos

```lisp
(defun sospechosos (agentes)
  (remove nil
          (mapcar (lambda (ag)
                    (if (and (= (nivel ag) 5)
                             (not (eq (base ag) 'morelia)))
                        (nombre ag)
                        nil))
                  agentes)))

(sospechosos *agentes*)
```

Resultado esperado: `(BETO)`.

Se revisan las dos condiciones del mensaje con `and`. Si se cumplen se devuelve el nombre; si no, `NIL`. `remove` elimina los `NIL`. La lista intermedia esperada es `(NIL BETO NIL NIL NIL NIL)`.

### Prueba 2: obtener los leales

```lisp
(defun leales (agentes traidor)
  (remove nil
          (mapcar (lambda (ag)
                    (if (eq (nombre ag) traidor) nil ag))
                  agentes)))

(leales *agentes* (car (sospechosos *agentes*)))
```

Resultado esperado:

```lisp
((ANA 28 3 MORELIA 120)
 (CARLA 22 1 MORELIA 45)
 (DIEGO 41 4 ZAMORA 210)
 (ELENA 30 2 PATZCUARO 90)
 (FAUSTO 26 5 MORELIA 400))
```

Se conservan los registros completos de quienes tienen un nombre distinto del traidor. El nombre a excluir se obtiene del filtro anterior.

### Prueba 3: sumar puntos

```lisp
(defun total-puntos (agentes)
  (reduce #'+ (mapcar #'puntos agentes) :initial-value 0))

(total-puntos (leales *agentes* (car (sospechosos *agentes*))))
```

Resultado esperado: `865`.

`mapcar` extrae `(120 45 210 90 400)` y `reduce` suma esos valores. Se usan los puntos originales, no los resultados de aplicar bonos.

### Prueba 4: promedio de edad

```lisp
(defun promedio-edad (agentes)
  (if (null agentes)
      (error "No se puede calcular el promedio de una lista vacia.")
      (/ (reduce #'+ (mapcar #'edad agentes))
         (length agentes))))

(promedio-edad (leales *agentes* (car (sospechosos *agentes*))))
```

Resultado esperado: `147/5`. Las edades suman 147 y hay cinco leales.

Para obtener el decimal:

```lisp
(float
  (promedio-edad (leales *agentes* (car (sospechosos *agentes*)))))
```

Resultado esperado: `29.4`.

Common Lisp conserva la division entre enteros como un numero racional exacto cuando corresponde. `float` lo convierte a punto flotante. La funcion incluye un error explicito si la lista esta vacia, porque no existe promedio sin datos.

### Deduccion

Beto y Fausto tienen nivel 5. La frase "fuera de Morelia" descarta a Fausto, cuya base es Morelia. Si solo se revisara el nivel, el filtro devolveria los dos nombres y no identificaria un unico sospechoso.

## Mision 5 — Codigo saboteado

**Estado:** analisis y correcciones preparados. Falta ejecutar los originales en GNU CLISP y copiar los mensajes reales. Los errores esperados de esta tabla no son transcripciones del interprete.

| ID | Fragmento original | Comportamiento previsto | Causa |
|---|---|---|---|
| S1 | `(mapcar car *agentes*)` | Error de variable sin valor, si CAR no esta ligada como variable. | Falta referenciar la funcion con `#'`. |
| S2 | `(mapcar (lambda ag (nombre ag)) *agentes*)` | Error en la lista de parametros. | Debe escribirse `(ag)`. |
| S3 | `(mapcar (lambda (ag) (puntos ag)) *agentes* *bonos*)` | Error por numero de argumentos. | Dos listas entregan dos argumentos a una funcion que acepta uno. |
| S4 | `(mapcar (lambda (ag b) (+ (puntos ag) b)) *agentes* '(10 0 5))` | Sin error; resultado `(130 340 50)`. | La lista de bonos solo tiene tres elementos. |
| S5 | `(mapcar '(lambda (ag) (nombre ag)) *agentes*)` | Se espera rechazo por recibir una lista en lugar de una funcion; registrar el comportamiento real de CLISP. | La comilla convierte la expresion lambda en datos; algunas implementaciones pueden admitir extensiones. |

### Versiones corregidas

```lisp
;;; S1
(mapcar #'car *agentes*)

;;; S2
(mapcar (lambda (ag) (nombre ag)) *agentes*)

;;; S3: se utilizan ambos argumentos para aplicar el bono.
(mapcar (lambda (ag b) (+ (puntos ag) b)) *agentes* *bonos*)

;;; S4: se entrega la lista completa de bonos.
(mapcar (lambda (ag b) (+ (puntos ag) b)) *agentes* *bonos*)

;;; S5: lambda sin la comilla que la convertia en datos.
(mapcar (lambda (ag) (nombre ag)) *agentes*)
```

S1, S2 y S5 corregidos deben devolver los seis nombres. S3 y S4 corregidos deben devolver `(130 340 50 230 105 400)`.

**Sabotaje silencioso:** S4. `mapcar` con varias listas termina al agotarse la mas corta; por eso faltan agentes sin que aparezca un error.

### Como obtener las evidencias

En el archivo completo los originales estan almacenados como datos para no impedir la carga. Ejecutar:

```lisp
(demostrar-mision-5)
```

La funcion muestra cada expresion y captura su error con `handler-case`, permitiendo continuar. Luego ejecuta las correcciones. Copiar al informe los mensajes exactos de esa ejecucion y contrastarlos con las predicciones propias, especialmente S5.

## Mision 6 — La fabrica de filtros

**Estado:** codigo incluido; salidas siguientes esperadas y pendientes de evidencia.

### Construccion de filtros

```lisp
(defun filtro-nivel (minimo)
  (lambda (ag) (>= (nivel ag) minimo)))

(defun filtro-base (ciudad)
  (lambda (ag) (eq (base ag) ciudad)))

(defun y-filtros (filtro1 filtro2)
  (lambda (ag)
    (and (funcall filtro1 ag) (funcall filtro2 ag))))

(defun aplicar-filtro (filtro agentes)
  (remove nil
          (mapcar (lambda (ag)
                    (if (funcall filtro ag) ag nil))
                  agentes)))
```

`filtro-nivel` devuelve una funcion que recuerda el minimo. `filtro-base` hace lo mismo con la ciudad. `funcall` permite ejecutar la funcion guardada en un parametro y `y-filtros` combina dos condiciones.

### Prueba 1: nivel 4 o mas

```lisp
(aplicar-filtro (filtro-nivel 4) *agentes*)
```

Resultado esperado:

```lisp
((BETO 35 5 URUAPAN 340)
 (DIEGO 41 4 ZAMORA 210)
 (FAUSTO 26 5 MORELIA 400))
```

### Prueba 2: agentes de Morelia

```lisp
(aplicar-filtro (filtro-base 'morelia) *agentes*)
```

Resultado esperado:

```lisp
((ANA 28 3 MORELIA 120)
 (CARLA 22 1 MORELIA 45)
 (FAUSTO 26 5 MORELIA 400))
```

### Prueba 3: Morelia y nivel 3 o mas

```lisp
(aplicar-filtro
  (y-filtros (filtro-base 'morelia) (filtro-nivel 3))
  *agentes*)
```

Resultado esperado:

```lisp
((ANA 28 3 MORELIA 120)
 (FAUSTO 26 5 MORELIA 400))
```

### Prueba 4: imprimir un informe

```lisp
(defun informe (agentes)
  (mapcar (lambda (ag)
            (format t "~A (~A) nivel ~D -> ~D pts~%"
                    (nombre ag) (base ag) (nivel ag) (puntos ag)))
          agentes)
  (length agentes))
```

`format` imprime una linea por agente. `~A` muestra los simbolos, `~D` los enteros y `~%` un salto de linea. Al terminar, la funcion devuelve cuantos agentes recibio.

### Ensamble final en una sola expresion

```lisp
(informe
  (aplicar-filtro
    (filtro-nivel 3)
    (leales *agentes* (car (sospechosos *agentes*)))))
```

Salida impresa esperada:

```text
ANA (MORELIA) nivel 3 -> 120 pts
DIEGO (ZAMORA) nivel 4 -> 210 pts
FAUSTO (MORELIA) nivel 5 -> 400 pts
```

Valor devuelto esperado: `3`. En el programa completo tambien se puede llamar `(ensamble-final)`.

### Ventaja de la fabrica

Con una sola definicion se pueden crear filtros de nivel 2, 3, 4 o 5 cambiando el argumento. No hace falta escribir una funcion distinta para cada minimo. Tambien se pueden combinar con filtros de ciudad.

## Notas generales de la actividad

- Los comandos `nano` y `clisp` se ejecutan en la terminal de Kali. Las expresiones entre parentesis se ejecutan dentro de CLISP.
- Despues de editar y guardar el archivo, hay que cargarlo de nuevo para que CLISP conozca los cambios.
- Una comilla antes de una lista indica que se trata como datos.
- `defun` crea una funcion con nombre y `lambda` permite escribir una funcion sin nombre.
- `mapcar` transforma elementos; para filtrar en esta practica se combina con `remove nil`.
- `reduce` combina los valores de una lista, por ejemplo para sumarlos.
- Los simbolos aparecen normalmente en mayusculas al imprimirlos.
- Las salidas esperadas sirven para comparar; la evidencia de entrega debe salir de la ejecucion propia.

## Ejecucion final y registro de resultados

Desde la carpeta donde se encuentra el archivo:

```bash
clisp -i mision_lambda.lisp
```

Dentro de CLISP, despues de anotar las predicciones:

```lisp
(dribble "salidas_lambda.txt")
(demostracion)
(dribble)
```

`demostracion` ejecuta las pruebas de las seis misiones. `dribble` permite guardar una transcripcion. Los errores intencionales de la mision 5 se capturan para que la demostracion continue.

## Autochequeo antes de entregar

- [ ] Conservar las predicciones personales de la mision 1 y explicar cualquier diferencia.
- [x] Comprobar los resultados a-f y las funciones de acceso.
- [x] Probar `mapcar` con una funcion existente, con lambda y con dos listas.
- [x] Obtener el mensaje y comprobar que las dos versiones de descifrado coinciden.
- [x] Volver a cifrar la palabra TRAIDOR.
- [ ] Ejecutar la comprobacion inversa del mensaje completo.
- [ ] Comprobar sospechosos, leales, puntos y promedio en CLISP.
- [ ] Registrar los errores o resultados reales de S1-S5 y sus correcciones.
- [ ] Ejecutar los tres filtros y el ensamble final de la mision 6.
- [ ] Verificar que el archivo completo carga sin errores en GNU CLISP.
- [ ] Incorporar todas las salidas pendientes a este informe.

## Conclusion

Las pruebas realizadas permitieron pasar de consultar campos individuales a transformar listas completas y descifrar un mensaje. Se comprobo que las funciones pueden reutilizarse: primero para un numero, despues para una palabra y finalmente para todo el mensaje. Tambien se identificaron errores de parentesis y de rutas de archivos, que se corrigieron durante la actividad.

El codigo completo incorpora filtros, sumas, promedios y funciones que generan otras funciones. Queda pendiente ejecutar esos ultimos apartados y registrar sus salidas para cerrar la evidencia de la actividad.
