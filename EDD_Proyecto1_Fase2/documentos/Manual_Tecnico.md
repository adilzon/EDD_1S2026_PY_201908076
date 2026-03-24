# Manual Técnico - Sistema MedTrack F2
**Universidad de San Carlos de Guatemala** **Facultad de Ingeniería** **Estructuras de Datos**

---

## 1. Descripción General
MedTrack F2 es una solución integral para la gestión hospitalaria que optimiza el control de inventarios y personal médico. El sistema utiliza estructuras de datos avanzadas para garantizar que las operaciones de búsqueda, inserción y reporte se realicen con una complejidad temporal mínima.

## 2. Arquitectura del Sistema
El software está desarrollado bajo un paradigma modular utilizando:
* **Lenguaje:** Perl 5.
* **Interfaz Gráfica:** GTK3 (GObject Introspection).
* **Renderizado de Estructuras:** Graphviz.
* **Formato de Intercambio de Datos:** JSON.

## 3. Especificación de Estructuras de Datos

### 3.1 Árbol AVL (Gestión de Médicos)
Se implementó un Árbol Binario de Búsqueda Equilibrado para el manejo de usuarios departamentales. 
* **Equilibrio:** Se utiliza el factor de balance (altura derecha - altura izquierda). Si el factor es > 1 o < -1, se ejecutan rotaciones (Simples o Dobles).
* **Complejidad:** Búsqueda y Escritura en $O(\log n)$.



### 3.2 Árbol B de Orden 4 (Suministros)
Para el inventario de suministros, donde el volumen de datos es mayor, se utilizó un Árbol B.
* **Propiedades:** Es un árbol multicamino donde cada nodo tiene un máximo de 3 claves y 4 hijos. 
* **Lógica de Split:** Al insertar una cuarta clave, el nodo se divide y la clave media promociona al nodo padre.



### 3.3 Árbol BST (Equipos Médicos)
Un árbol de búsqueda binaria estándar para organizar equipos médicos por su código alfanumérico. Permite recorridos In-Order para visualizar el inventario alfabéticamente.

### 3.4 Matriz Dispersa (Citas Médicas)
Estructura ortogonal que utiliza cabeceras para Filas (Médicos) y Columnas (Fechas). 
* **Eficiencia:** Solo se reserva memoria para celdas con datos, optimizando el uso de recursos en comparación con una matriz estática.



## 4. Algoritmos Principales
* **Parsing JSON:** Uso del módulo `JSON` para transformar cadenas de texto en referencias de hashes y arreglos de Perl.
* **Generación de DOT:** Recorrido recursivo de los árboles para escribir la sintaxis de Graphviz y generar imágenes PNG mediante llamadas al sistema.