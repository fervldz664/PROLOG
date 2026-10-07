;;; OPERACION LAMBDA - GNU CLISP / Common Lisp
;;; Cargar: clisp -i mision_lambda.lisp
;;; Ejecutar demostraciones: (demostracion)
;;; Las demostraciones NO se ejecutan al cargar: anota primero tus predicciones.
;;; No se usan loop, dolist ni do. Recorridos mediante mapcar.

;;; MATERIAL INTERCEPTADO
(defparameter *agentes*
  '((ana 28 3 morelia 120)
    (beto 35 5 uruapan 340)
    (carla 22 1 morelia 45)
    (diego 41 4 zamora 210)
    (elena 30 2 patzcuaro 90)
    (fausto 26 5 morelia 400)))
(defparameter *alfabeto*
  '(a b c d e f g h i j k l m n o p q r s t u v w x y z))
(defparameter *interceptado*
  '((22 20 3 11 6 17 20) (16 11 24 7 14) (5 11 16 5 17)
    (8 23 7 20 3) (6 7) (15 17 20 7 14 11 3)))
(defparameter *bonos* '(10 0 5 20 15 0))

;;; MISION 1 - ACCESO SOLO CON CAR Y CDR
(defun nombre (ag) (car ag))
(defun edad (ag) (car (cdr ag)))
(defun nivel (ag) (car (cdr (cdr ag))))
(defun base (ag) (car (cdr (cdr (cdr ag)))))
(defun puntos (ag) (car (cdr (cdr (cdr (cdr ag))))))

(defun puntos-de-elena ()
  (puntos (car (cdr (cdr (cdr (cdr *agentes*)))))))

;;; Expresiones de la tabla; E se expande para usar solo car y cdr.
;;; Original E: (caddr (cadr *agentes*))
(defparameter *expresiones-mision-1*
  '((a (car (cdr (car *agentes*))))
    (b (car (car (cdr *agentes*))))
    (c (cdr (car (cdr (cdr *agentes*)))))
    (d (car (cdr (cdr (cdr (car (cdr (cdr (cdr *agentes*)))))))))
    (e (car (cdr (cdr (car (cdr *agentes*))))))
    (f (car (cdr (cdr (car (cdr (cdr (cdr (cdr *agentes*)))))))))))
;;; Resultados esperados: 28, BETO, (22 1 MORELIA 45), ZAMORA, 5, 2.
;;; (car (cdr '(ana))) => NIL. No es error: car de NIL es NIL.
;;; Un campo ausente puede pasar inadvertido y fallar en calculos posteriores.

;;; MISION 2 - MAPCAR, LAMBDA, CONS Y LIST
(defun pase-de-lista (agentes)
  (mapcar #'nombre agentes))
(defun nombre-y-nivel (agentes)
  (mapcar (lambda (ag) (cons (nombre ag) (nivel ag))) agentes))
(defun cumpleanios (agentes)
  (mapcar (lambda (ag) (list (nombre ag) (+ (edad ag) 1))) agentes))
(defun aplicar-bonos (agentes bonos)
  (mapcar (lambda (ag bono) (+ (puntos ag) bono)) agentes bonos))
;;; #'car referencia una funcion; car sin comillas como argumento se evalua
;;; como variable. Lo mismo sucede con #'nombre.
;;; Estas funciones construyen resultados sin modificar *agentes*.

;;; MISION 3 - CIFRADO CESAR, A = 0, DESPLAZAMIENTO = 3
(defun descifrar-codigo (n)
  (nth (mod (- n 3) 26) *alfabeto*))
(defun descifrar-palabra (palabra)
  (mapcar #'descifrar-codigo palabra))
(defun descifrar-mensaje (mensaje)
  (mapcar #'descifrar-palabra mensaje))
(defun descifrar-mensaje-lambda (mensaje)
  (mapcar (lambda (palabra)
            (mapcar (lambda (n)
                      (nth (mod (- n 3) 26) *alfabeto*))
                    palabra))
          mensaje))
;;; Expresion independiente solicitada, para pegar en CLISP:
;;; (mapcar (lambda (palabra)
;;;           (mapcar (lambda (n) (nth (mod (- n 3) 26) *alfabeto*))
;;;                   palabra))
;;;         *interceptado*)
;;; Mensaje: TRAIDOR NIVEL CINCO FUERA DE MORELIA.
(defun cifrar-palabra (palabra)
  (mapcar (lambda (letra)
            (mod (+ (position letra *alfabeto*) 3) 26))
          palabra))
(defun comprobar-cifrado ()
  (equal (mapcar #'cifrar-palabra (descifrar-mensaje *interceptado*))
         *interceptado*))

;;; MISION 4 - FILTRAR Y AGREGAR
(defun sospechosos (agentes)
  (remove nil
          (mapcar (lambda (ag)
                    (if (and (= (nivel ag) 5)
                             (not (eq (base ag) 'morelia)))
                        (nombre ag)
                        nil))
                  agentes)))
(defun leales (agentes traidor)
  (remove nil
          (mapcar (lambda (ag)
                    (if (eq (nombre ag) traidor) nil ag))
                  agentes)))
(defun total-puntos (agentes)
  (reduce #'+ (mapcar #'puntos agentes) :initial-value 0))
(defun promedio-edad (agentes)
  (if (null agentes)
      (error "No se puede calcular el promedio de una lista vacia.")
      (/ (reduce #'+ (mapcar #'edad agentes)) (length agentes))))
;;; Sospechoso: BETO. Leales: ANA, CARLA, DIEGO, ELENA y FAUSTO.
;;; Puntos de leales: 865. Edades: 147/5, racional exacto.
;;; (float (promedio-edad ...)) produce 29.4, en punto flotante.
;;; Fausto queda descartado por estar en Morelia. Solo nivel daria dos nombres.

;;; MISION 5 - CODIGO SABOTEADO
;;; Se guardan como DATOS: no se ejecutan al cargar el archivo.
;;; Antes de llamar (demostrar-mision-5), registra tus predicciones.
(defparameter *sabotajes*
  '((s1 (mapcar car *agentes*))
    (s2 (mapcar (lambda ag (nombre ag)) *agentes*))
    (s3 (mapcar (lambda (ag) (puntos ag)) *agentes* *bonos*))
    (s4 (mapcar (lambda (ag b) (+ (puntos ag) b)) *agentes* '(10 0 5)))
    (s5 (mapcar '(lambda (ag) (nombre ag)) *agentes*))))
;;; S1: car se interpreta como variable sin valor. Usar #'car.
;;; S2: parametros de lambda deben estar en una lista: (ag).
;;; S3: dos listas requieren una funcion que acepte dos argumentos.
;;; S4: sabotaje silencioso: mapcar termina al agotarse la lista mas corta.
;;;     Solo produce (130 340 50). Usar la lista completa de bonos.
;;; S5: quote construye una lista, no una funcion. Usar lambda sin quote.
;;;     Se registra el comportamiento real del interprete por si admite
;;;     extensiones; la forma corregida es portable en Common Lisp.
(defparameter *correcciones*
  '((s1 (mapcar #'car *agentes*))
    (s2 (mapcar (lambda (ag) (nombre ag)) *agentes*))
    (s3 (mapcar (lambda (ag b) (+ (puntos ag) b)) *agentes* *bonos*))
    (s4 (mapcar (lambda (ag b) (+ (puntos ag) b)) *agentes* *bonos*))
    (s5 (mapcar (lambda (ag) (nombre ag)) *agentes*))))

(defun probar-expresion (expresion)
  ;; Captura errores para poder seguir con los demas ejercicios.
  ;; EVAL se usa solamente para demostrar los fragmentos de la practica.
  (format t "~&Expresion: ~S~%" expresion)
  (handler-case
      (let ((resultado (eval expresion)))
        (format t "Resultado: ~S~%" resultado)
        resultado)
    (error (condicion)
      (format t "ERROR [~S]: ~A~%" (type-of condicion) condicion)
      nil)))
(defun demostrar-mision-5 ()
  (mapcar (lambda (caso)
            (format t "~%Original ~A~%" (car caso))
            (probar-expresion (car (cdr caso))))
          *sabotajes*)
  (mapcar (lambda (caso)
            (format t "~%Correccion ~A~%" (car caso))
            (probar-expresion (car (cdr caso))))
          *correcciones*)
  (values))

;;; MISION 6 - FABRICA DE FILTROS (CIERRES LEXICOS)
(defun filtro-nivel (minimo)
  (lambda (ag) (>= (nivel ag) minimo)))
(defun filtro-base (ciudad)
  (lambda (ag) (eq (base ag) ciudad)))
(defun y-filtros (filtro1 filtro2)
  (lambda (ag) (and (funcall filtro1 ag) (funcall filtro2 ag))))
(defun aplicar-filtro (filtro agentes)
  (remove nil
          (mapcar (lambda (ag) (if (funcall filtro ag) ag nil)) agentes)))
(defun informe (agentes)
  (mapcar (lambda (ag)
            (format t "~A (~A) nivel ~D -> ~D pts~%"
                    (nombre ag) (base ag) (nivel ag) (puntos ag)))
          agentes)
  (length agentes))
(defun ensamble-final ()
  (informe
   (aplicar-filtro (filtro-nivel 3)
                   (leales *agentes* (car (sospechosos *agentes*))))))
;;; La expresion dentro de ensamble-final resuelve el punto 7.
;;; Imprime ANA, DIEGO y FAUSTO y devuelve 3.
;;; La fabrica permite crear filtros para 2, 3, 4 o 5 sin repetir definiciones.
;;; Cada lambda recuerda el minimo o ciudad recibido al construirla.

;;; DEMOSTRACIONES - ejecutar despues de registrar predicciones propias.
(defun mostrar (etiqueta valor)
  (format t "~&~A: ~S~%" etiqueta valor)
  valor)
(defun demostracion ()
  (format t "~%=== MISION 1 ===~%")
  (mapcar (lambda (caso)
            (mostrar (car caso) (eval (car (cdr caso)))))
          *expresiones-mision-1*)
  (mostrar "Puntos de Elena" (puntos-de-elena))
  (mostrar "Registro incompleto" (car (cdr '(ana))))
  (format t "~%=== MISION 2 ===~%")
  (mostrar "Pase de lista" (pase-de-lista *agentes*))
  (mostrar "Nombre y nivel" (nombre-y-nivel *agentes*))
  (mostrar "Cumpleanios" (cumpleanios *agentes*))
  (mostrar "Edad original de Ana" (edad (car *agentes*)))
  (mostrar "Bonos" (aplicar-bonos *agentes* *bonos*))
  (format t "~%=== MISION 3 ===~%")
  (mostrar "Codigo 22" (descifrar-codigo 22))
  (mostrar "Primera palabra" (descifrar-palabra (car *interceptado*)))
  (mostrar "Mensaje" (descifrar-mensaje *interceptado*))
  (mostrar "Lambdas anidadas" (descifrar-mensaje-lambda *interceptado*))
  (mostrar "Coinciden versiones"
           (equal (descifrar-mensaje *interceptado*)
                  (descifrar-mensaje-lambda *interceptado*)))
  (mostrar "Cifrar TRAIDOR" (cifrar-palabra '(t r a i d o r)))
  (mostrar "Cifrado reversible" (comprobar-cifrado))
  (format t "~%=== MISION 4 ===~%")
  (mostrar "Sospechosos" (sospechosos *agentes*))
  (let ((grupo (leales *agentes* (car (sospechosos *agentes*)))))
    (mostrar "Leales" grupo)
    (mostrar "Total de puntos" (total-puntos grupo))
    (mostrar "Promedio exacto" (promedio-edad grupo))
    (mostrar "Promedio decimal" (float (promedio-edad grupo))))
  (format t "~%=== MISION 5: errores intencionales capturados ===~%")
  (demostrar-mision-5)
  (format t "~%=== MISION 6 ===~%")
  (mostrar "Nivel 4 o mas" (aplicar-filtro (filtro-nivel 4) *agentes*))
  (mostrar "Morelia" (aplicar-filtro (filtro-base 'morelia) *agentes*))
  (mostrar "Morelia y nivel 3 o mas"
           (aplicar-filtro (y-filtros (filtro-base 'morelia) (filtro-nivel 3))
                           *agentes*))
  (format t "~%Informe final de leales de nivel 3 o mas:~%")
  (mostrar "Agentes reportados" (ensamble-final))
  (values))

;;; USO INTERACTIVO:
;;; (demostracion)            ; Todas las misiones y salidas reales.
;;; (demostrar-mision-5)      ; Solo errores y correcciones.
;;; (ensamble-final)          ; Informe final.
;;; Para guardar una transcripcion desde CLISP:
;;; (dribble "salidas_lambda.txt")
;;; (demostracion)
;;; (dribble)
;;; El informe_lambda.md se entrega por separado con tus predicciones,
;;; resultados reales y respuestas. No inventes predicciones ni errores.
