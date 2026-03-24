# Manual de Usuario - MedTrack F2
**Guía del Operador del Sistema**

---

## 1. Introducción
Bienvenido al sistema MedTrack F2. Este manual le guiará a través de las funciones de administración y consulta de personal y suministros médicos.

## 2. Requisitos de Instalación
Para que el sistema funcione correctamente, su equipo debe contar con:
1. **Intérprete de Perl:** Versión 5.10 o superior.
2. **GTK3:** Librerías de desarrollo instaladas en el SO.
3. **Graphviz:** Debe estar accesible desde la terminal (comando `dot`).

## 3. Guía de Inicio de Sesión
Al ejecutar el programa, se mostrará la ventana de autenticación:
* **Administrador:** Ingrese sus credenciales para acceder a la configuración global.
* **Médico:** Use su número de colegiado como usuario.



## 4. Funciones del Administrador
### 4.1 Carga Masiva
El sistema permite cargar cientos de registros en segundos.
1. Haga clic en el botón **"Carga Masiva"**.
2. Seleccione el archivo `.json` correspondiente (Usuarios o Inventario).
3. El sistema notificará si la carga fue exitosa.

### 4.2 Visualización de Reportes
Para auditar la información, el administrador puede generar mapas visuales de las estructuras:
* Vaya a la pestaña de **Reportes**.
* Seleccione el árbol que desea visualizar.
* El sistema abrirá automáticamente la imagen generada por Graphviz.

## 5. Gestión de Inventario
Dentro del Dashboard, podrá ver dos secciones:
1. **Equipos Médicos:** Listado detallado proveniente del Árbol BST.
2. **Suministros:** Visualización por bloques proveniente del Árbol B.

## 6. Resolución de Problemas
* **El programa no abre:** Verifique que el módulo `Gtk3` esté instalado correctamente ejecutando `cpan Gtk3`.
* **Los reportes no aparecen:** Asegúrese de que la carpeta `reportes/` tenga permisos de escritura.