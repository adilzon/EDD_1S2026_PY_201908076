package Dashboard;

use strict;
use warnings;
use Gtk3;

sub mostrar {
    my ($rol) = @_; # Recibe si es 'admin' o 'medico'

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("MedTrack F2 - Dashboard ($rol)");
    $ventana->set_default_size(800, 600);
    $ventana->set_position('center');

    # Contenedor principal
    my $vbox = Gtk3::Box->new('vertical', 5);
    $ventana->add($vbox);

    # Barra de título o saludo
    my $lbl_bienvenida = Gtk3::Label->new("Bienvenido, sesion iniciada como: $rol");
    $vbox->pack_start($lbl_bienvenida, 0, 0, 10);

    # Creamos un Notebook (Pestañas)
    my $notebook = Gtk3::Notebook->new();
    $vbox->pack_start($notebook, 1, 1, 0);

    # --- PESTAÑA 1: GESTIÓN DE INVENTARIO (Solo para Admin o según el PDF) ---
    my $caja_inventario = Gtk3::Box->new('vertical', 10);
    
    my $btn_carga_inv = Gtk3::Button->new_with_label("Cargar Inventario (JSON)");
    my $btn_ver_bst = Gtk3::Button->new_with_label("Ver Árbol BST (Equipos)");
    my $btn_ver_b = Gtk3::Button->new_with_label("Ver Árbol B (Suministros)");
    
    $caja_inventario->pack_start($btn_carga_inv, 0, 0, 5);
    $caja_inventario->pack_start($btn_ver_bst, 0, 0, 5);
    $caja_inventario->pack_start($btn_ver_b, 0, 0, 5);
    
    $notebook->append_page($caja_inventario, Gtk3::Label->new("Inventario"));

    # --- PESTAÑA 2: USUARIOS (Solo Admin) ---
    if ($rol eq 'admin') {
        my $caja_usuarios = Gtk3::Box->new('vertical', 10);
        my $btn_carga_users = Gtk3::Button->new_with_label("Carga Masiva Médicos (AVL)");
        my $btn_ver_avl = Gtk3::Button->new_with_label("Generar Reporte AVL");
        
        $caja_usuarios->pack_start($btn_carga_users, 0, 0, 5);
        $caja_usuarios->pack_start($btn_ver_avl, 0, 0, 5);
        
        $notebook->append_page($caja_usuarios, Gtk3::Label->new("Usuarios"));
    }

    # Botón de Cerrar Sesión
    my $btn_logout = Gtk3::Button->new_with_label("Cerrar Sesión");
    $btn_logout->signal_connect(clicked => sub {
        $ventana->destroy();
    });
    $vbox->pack_start($btn_logout, 0, 0, 10);

    $ventana->show_all();
}

1;