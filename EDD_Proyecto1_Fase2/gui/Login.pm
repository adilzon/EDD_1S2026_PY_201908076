package Login; # Nombre del paquete (debe coincidir con el nombre del archivo)

use strict;
use warnings;
use Gtk3; # Cargamos la librería gráfica

sub mostrar {
    # 1. Crear la ventana principal
    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("MedTrack F2 - Autenticación");
    $ventana->set_default_size(300, 250);
    $ventana->set_border_width(15);
    $ventana->set_position('center');

    # 2. Contenedor Vertical (VBox) para apilar los elementos
    # El '10' es el espacio en píxeles entre cada elemento
    my $vbox = Gtk3::Box->new('vertical', 10);
    $ventana->add($vbox);

    # 3. Elementos de la interfaz (Etiquetas y Entradas de texto)
    my $lbl_titulo = Gtk3::Label->new("INICIO DE SESIÓN");
    $vbox->pack_start($lbl_titulo, 0, 0, 5);

    # Campo de Usuario (ID/Colegiado)
    my $lbl_user = Gtk3::Label->new("Número de Colegiado:");
    $vbox->pack_start($lbl_user, 0, 0, 0);
    my $txt_user = Gtk3::Entry->new(); # Cuadro de texto
    $vbox->pack_start($txt_user, 0, 0, 0);

    # Campo de Contraseña
    my $lbl_pass = Gtk3::Label->new("Contraseña:");
    $vbox->pack_start($lbl_pass, 0, 0, 0);
    my $txt_pass = Gtk3::Entry->new();
    $txt_pass->set_visibility(0); # Hace que el texto se vea como puntos (***)
    $vbox->pack_start($txt_pass, 0, 0, 0);

    # 4. Botón de Entrar
    my $btn_entrar = Gtk3::Button->new_with_label("Ingresar");
    $vbox->pack_start($btn_entrar, 0, 0, 10);

    # --- LÓGICA DEL BOTÓN ---
    $btn_entrar->signal_connect(clicked => sub {
        my $usuario = $txt_user->get_text();
        my $password = $txt_pass->get_text();
        
        # Por ahora, una validación simple para probar
        if ($usuario eq "admin" && $password eq "1234") {
            print "¡Acceso concedido al Administrador!\n";
        } else {
            print "Usuario o contraseña incorrectos.\n";
        }
    });

    # 5. Cerrar el programa al cerrar la ventana
    $ventana->signal_connect(destroy => sub { Gtk3::main_quit(); });

    # Mostrar todo
    $ventana->show_all();
}

1; # Siempre terminar con 1