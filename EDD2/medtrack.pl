#!/usr/bin/perl
use strict;
use warnings;
use Gtk3 '-init';
use Glib qw(TRUE FALSE);

# =============================================
# VARIABLES GLOBALES
# =============================================
my $window;
my $notebook;

# =============================================
# VENTANA PRINCIPAL
# =============================================
sub crear_ventana_principal {
    $window = Gtk3::Window->new('toplevel');
    $window->set_title("EDD MedTrack - Fase 2");
    $window->set_default_size(900, 600);
    $window->set_position('center');
    $window->signal_connect('destroy' => sub { Gtk3::main_quit(); });

    my $vbox = Gtk3::Box->new('vertical', 0);
    $window->add($vbox);

    # Logo y título
    my $header = Gtk3::Label->new();
    $header->set_markup("<span size='x-large' weight='bold'>EDD MedTrack F2 EST</span>");
    $vbox->pack_start($header, FALSE, FALSE, 10);

    # Notebook (pestañas)
    $notebook = Gtk3::Notebook->new();
    $vbox->pack_start($notebook, TRUE, TRUE, 0);

    # Pestaña Login
    my $login_tab = crear_pestana_login();
    $notebook->append_page($login_tab, Gtk3::Label->new("Iniciar Sesión"));

    # Pestaña Registro
    my $registro_tab = crear_pestana_registro();
    $notebook->append_page($registro_tab, Gtk3::Label->new("Registrarse"));

    $window->show_all();
}

# =============================================
# PESTAÑA LOGIN
# =============================================
sub crear_pestana_login {
    my $box = Gtk3::Box->new('vertical', 10);
    $box->set_border_width(20);

    my $lbl = Gtk3::Label->new("Iniciar Sesión");
    $lbl->set_markup("<span size='large'>Iniciar Sesión</span>");
    $box->pack_start($lbl, FALSE, FALSE, 10);

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(10);
    $grid->set_column_spacing(10);
    $box->pack_start($grid, FALSE, FALSE, 0);

    $grid->attach(Gtk3::Label->new("Número de Colegio / Usuario:"), 0, 0, 1, 1);
    my $entry_user = Gtk3::Entry->new();
    $grid->attach($entry_user, 1, 0, 1, 1);

    $grid->attach(Gtk3::Label->new("Contraseña:"), 0, 1, 1, 1);
    my $entry_pass = Gtk3::Entry->new();
    $entry_pass->set_visibility(FALSE);
    $grid->attach($entry_pass, 1, 1, 1, 1);

    my $btn_login = Gtk3::Button->new("Iniciar Sesión");
    $btn_login->signal_connect('clicked' => sub {
        my $user = $entry_user->get_text();
        my $pass = $entry_pass->get_text();

        if ($user eq "AdminHospital" && $pass eq "MedTrack2025") {
            Gtk3::MessageDialog->new($window, 'modal', 'info', 'ok', "Bienvenido Administrador")->run();
            # Aquí más adelante abriremos el menú de administrador
        } elsif ($user eq "DEP001" && $pass eq "1234") {
            Gtk3::MessageDialog->new($window, 'modal', 'info', 'ok', "Bienvenido Usuario DEP001")->run();
        } else {
            Gtk3::MessageDialog->new($window, 'modal', 'error', 'ok', "Credenciales incorrectas")->run();
        }
    });
    $box->pack_start($btn_login, FALSE, FALSE, 10);

    return $box;
}

# =============================================
# PESTAÑA REGISTRO (por ahora básica)
# =============================================
sub crear_pestana_registro {
    my $box = Gtk3::Box->new('vertical', 10);
    $box->set_border_width(20);

    my $lbl = Gtk3::Label->new("Registro de Usuario");
    $lbl->set_markup("<span size='large'>Registro de Usuario</span>");
    $box->pack_start($lbl, FALSE, FALSE, 10);

    my $lbl_info = Gtk3::Label->new("Funcionalidad completa se implementará en la siguiente fase.");
    $box->pack_start($lbl_info, FALSE, FALSE, 20);

    return $box;
}

# =============================================
# INICIO DEL PROGRAMA
# =============================================
crear_ventana_principal();
Gtk3::main();