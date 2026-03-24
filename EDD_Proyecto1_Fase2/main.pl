#!/usr/bin/perl
use strict;
use warnings;

# Le decimos a Perl que busque nuestros módulos en las carpetas locales
use lib './gui';
use lib './modulos';

# Cargamos el módulo de Login que acabamos de crear
use Login;
use Gtk3 -init;

# Iniciamos la interfaz
Login::mostrar();

# El loop principal de Gtk3 mantiene la ventana abierta
Gtk3::main();