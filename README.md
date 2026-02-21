1. Introducción

El sistema MedTrack es una aplicación de consola desarrollada en Perl, cuyo objetivo es administrar el inventario de medicamentos de una farmacia, gestionar proveedores y entregas, y permitir la comparación de precios mediante estructuras de datos avanzadas.

El proyecto se diseñó siguiendo un enfoque modular, donde cada estructura de datos se implementa en un archivo independiente dentro de la carpeta estructuras, facilitando la escalabilidad, mantenimiento y reutilización del código.

2. Arquitectura General del Sistema

El sistema está compuesto por los siguientes módulos principales:

Medicamento.pm

ListaInventario.pm

Proveedor.pm

ListaProveedores.pm

Entrega.pm

ListaEntregas.pm

MatrizDispersa.pm

main.pl

Cada módulo representa una estructura de datos específica o una entidad del dominio del problema.

3. Estructuras de Datos Implementadas
3.1 Lista Doblemente Enlazada – Inventario de Medicamentos

Archivo: ListaInventario.pm
Nodo: Medicamento.pm

Descripción

El inventario de medicamentos se implementó mediante una lista doblemente enlazada ordenada por código de medicamento.

Cada nodo contiene:

Código

Nombre

Principio activo

Laboratorio

Cantidad en stock

Fecha de vencimiento

Precio

Nivel mínimo de reorden

Punteros siguiente y anterior

Decisiones de diseño

Se eligió una lista doblemente enlazada para permitir recorridos eficientes en ambos sentidos.

El orden por código facilita búsquedas estructuradas y reportes ordenados.

La validación de fechas se realiza con Time::Piece para detectar medicamentos próximos a vencer.

Se incorporaron alertas automáticas por:

Bajo stock

Próxima fecha de vencimiento

3.2 Lista Simple – Entregas por Proveedor

Archivo: ListaEntregas.pm
Nodo: Entrega.pm

Descripción

Cada proveedor mantiene una lista simple enlazada de entregas, donde cada entrega representa una transacción realizada por dicho proveedor.

Cada entrega contiene:

Fecha

Número de factura

Medicamento entregado

Cantidad

Precio unitario

Índice del medicamento

Puntero siguiente

Decisiones de diseño

Se utilizó una lista simple porque las entregas solo requieren recorrido secuencial.

La estructura permite mantener el historial completo de entregas por proveedor.

Cada entrega se enlaza automáticamente al proveedor correspondiente.

3.3 Lista Doblemente Enlazada – Proveedores

Archivo: Proveedor.pm y ListaProveedores.pm

Descripción

Los proveedores se almacenan en una lista doblemente enlazada, donde cada proveedor contiene su propia lista de entregas.

Cada proveedor incluye:

Código / NIT

Nombre

Teléfono

Índice automático

Lista simple de entregas

Decisiones de diseño

Se asigna un índice automático a cada proveedor para ser utilizado en la matriz dispersa.

La estructura permite agregar proveedores dinámicamente.

Se mantiene la separación entre proveedor y entregas para mayor claridad estructural.

3.4 Matriz Dispersa – Comparación de Precios

Archivo: MatrizDispersa.pm

Descripción

La comparación de precios entre proveedores y medicamentos se implementó mediante una matriz dispersa, donde:

Filas → Proveedores

Columnas → Medicamentos

Valor → Precio unitario ofrecido

Solo se almacenan posiciones donde existe una relación real entre proveedor y medicamento.

Decisiones de diseño

Se eligió una matriz dispersa para optimizar memoria, ya que no todos los proveedores venden todos los medicamentos.

La matriz se actualiza automáticamente al registrar una entrega.

Permite consultas eficientes para comparar precios de un medicamento entre distintos proveedores.

4. Integración de Estructuras

Al registrar una entrega:

Se agrega a la lista simple del proveedor.

Se actualiza la cantidad en el inventario.

Se inserta el precio en la matriz dispersa usando índices automáticos.

Los índices de proveedores y medicamentos permiten una integración limpia entre listas y matriz.

5. Carga Masiva de Datos

Archivo: ListaInventario.pm

Se implementó la carga masiva desde archivos CSV con el siguiente orden:

codigo,nombre,principio,laboratorio,precio,cantidad,vencimiento,minimo

El sistema valida:

Formato de fecha

Valores numéricos

Campos obligatorios

Esto garantiza consistencia y evita errores en tiempo de ejecución.

6. Reportes y Visualización

Se implementaron reportes gráficos utilizando Graphviz, generando archivos .dot y .png para:

Inventario de medicamentos

Lista de proveedores

Los reportes se actualizan automáticamente cuando se modifican las estructuras.

7. Decisiones Generales de Diseño

Separación estricta por módulos

Uso de estructuras de datos solicitadas explícitamente en el proyecto

Código orientado a claridad y mantenimiento

Validaciones fuertes en entrada de datos

Preparación del sistema para futuras extensiones (usuarios departamentales y solicitudes)

8. Conclusión

El sistema MedTrack cumple con la implementación de las principales estructuras de datos solicitadas, integrándolas de forma coherente para resolver el problema de gestión farmacéutica.
El diseño modular permite escalar el sistema y agregar nuevas funcionalidades sin comprometer la estabilidad del núcleo.

9. Autor

Nombre del estudiante:Adilzon Alfredo Velásquez Hernández
Curso: Estructuras de Datos
Lenguaje: Perl
Proyecto: MedTrack
