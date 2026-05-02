#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use lib 'lib';
use POSIX qw(setlocale LC_NUMERIC);
setlocale(LC_NUMERIC, "C");
use Gtk3;
use Glib qw(TRUE FALSE);

use ListaDobleEnlazada;
use ArbolBST;
use ArbolB;
use ArbolAVL;
use ListaCircularDobleProveedores;
use MatrizDispersaProveedorFabricante;
use CargaJSON;

# ====================== ESTRUCTURAS ======================

my $lista_medicamentos = ListaDobleEnlazada->new();
my $bst_equipos        = ArbolBST->new();
my $btree_suministros  = ArbolB->new();
my $avl_personal       = ArbolAVL->new();
my $lista_proveedores  = ListaCircularDobleProveedores->new();
my $matriz             = MatrizDispersaProveedorFabricante->new();

my $usuario_actual;

Gtk3::init();

# ====================== LOGIN ======================

my $win_login = Gtk3::Window->new('toplevel');
$win_login->set_title("EDD MedTrack");
$win_login->set_default_size(520,400);
$win_login->set_border_width(20);
$win_login->signal_connect(destroy => sub { Gtk3::main_quit(); });

my $box = Gtk3::Box->new('vertical',15);
$win_login->add($box);

my $title = Gtk3::Label->new("EDD MedTrack");
$box->pack_start($title,FALSE,FALSE,10);

$box->pack_start(Gtk3::Label->new("Usuario / Numero de Colegio:"),FALSE,FALSE,5);

my $entry_user = Gtk3::Entry->new();
$box->pack_start($entry_user,FALSE,FALSE,5);

$box->pack_start(Gtk3::Label->new("Contrasena:"),FALSE,FALSE,5);

my $entry_pass = Gtk3::Entry->new();
$entry_pass->set_visibility(FALSE);
$box->pack_start($entry_pass,FALSE,FALSE,5);

my $btn_login = Gtk3::Button->new("Iniciar Sesion");
$box->pack_start($btn_login,FALSE,FALSE,15);

my $status = Gtk3::Label->new("");
$box->pack_start($status,FALSE,FALSE,5);

# ====================== LOGIN LOGICA ======================

$btn_login->signal_connect(clicked => sub {

    my $user = $entry_user->get_text();
    my $pass = $entry_pass->get_text();

    if($user eq "AdminHospital" && $pass eq "MedTrack2025")
    {
        $usuario_actual = "ADMIN";
        $win_login->hide();
        mostrar_panel_admin();
        return;
    }

    my $nodo = $avl_personal->buscar($user);

    if(defined $nodo && $nodo->obtener_contrasena eq $pass)
    {
        $usuario_actual = $nodo;
        $win_login->hide();

        if($nodo->obtener_tipo eq "TIPO-05"){
            mostrar_panel_tipo5();
        } else {
            mostrar_panel_usuario();
        }
    }
    else
    {
        $status->set_text("Credenciales incorrectas");
    }

});

# ====================== TABLA GTK ======================

sub mostrar_tabla {

    my ($titulo, $columnas, $datos) = @_;

    my $win = Gtk3::Window->new('toplevel');
    $win->set_title($titulo);
    $win->set_default_size(900,500);

    my $vbox = Gtk3::Box->new('vertical',5);
    $win->add($vbox);

    my $store = Gtk3::ListStore->new(('Glib::String') x scalar(@$columnas));

    foreach my $fila (@$datos)
    {
        my $iter = $store->append();
        for(my $i=0;$i<@$fila;$i++)
        {
            $store->set($iter,$i,$fila->[$i]);
        }
    }

    my $tree = Gtk3::TreeView->new($store);

    for(my $i=0;$i<@$columnas;$i++)
    {
        my $renderer = Gtk3::CellRendererText->new();
        my $column = Gtk3::TreeViewColumn->new_with_attributes(
            $columnas->[$i],
            $renderer,
            text=>$i
        );
        $tree->append_column($column);
    }

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->add($tree);

    $vbox->pack_start($scroll,TRUE,TRUE,5);

    $win->show_all();
}

# ====================== RECORRIDOS ======================

sub recorrer_avl {
    my ($nodo, $arr, $tipo) = @_;
    return unless defined $nodo;

    if ($tipo eq "pre") {
        push @$arr, [
            $nodo->obtener_numero_colegio // '',
            $nodo->obtener_nombre // '',
            $nodo->obtener_tipo // '',
            $nodo->obtener_especialidad // '',
            $nodo->obtener_departamento // ''
        ];
    }

    recorrer_avl($nodo->{izquierda}, $arr, $tipo);

    if ($tipo eq "in") {
        push @$arr, [
            $nodo->obtener_numero_colegio // '',
            $nodo->obtener_nombre // '',
            $nodo->obtener_tipo // '',
            $nodo->obtener_especialidad // '',
            $nodo->obtener_departamento // ''
        ];
    }

    recorrer_avl($nodo->{derecha}, $arr, $tipo);

    if ($tipo eq "post") {
        push @$arr, [
            $nodo->obtener_numero_colegio // '',
            $nodo->obtener_nombre // '',
            $nodo->obtener_tipo // '',
            $nodo->obtener_especialidad // '',
            $nodo->obtener_departamento // ''
        ];
    }
}

sub recorrer_bst {
    my ($nodo, $arr, $tipo) = @_;
    return unless defined $nodo;

    if ($tipo eq "pre") {
        push @$arr, [
            $nodo->obtener_codigo // '',
            $nodo->obtener_nombre // '',
            $nodo->obtener_fabricante // '',
            $nodo->obtener_precio // 0,
            $nodo->obtener_cantidad // 0,
            $nodo->obtener_fecha_ingreso // '',
            $nodo->obtener_nivel_minimo // 0
        ];
    }

    recorrer_bst($nodo->{izquierda}, $arr, $tipo);

    if ($tipo eq "in") {
        push @$arr, [
            $nodo->obtener_codigo // '',
            $nodo->obtener_nombre // '',
            $nodo->obtener_fabricante // '',
            $nodo->obtener_precio // 0,
            $nodo->obtener_cantidad // 0,
            $nodo->obtener_fecha_ingreso // '',
            $nodo->obtener_nivel_minimo // 0
        ];
    }

    recorrer_bst($nodo->{derecha}, $arr, $tipo);

    if ($tipo eq "post") {
        push @$arr, [
            $nodo->obtener_codigo // '',
            $nodo->obtener_nombre // '',
            $nodo->obtener_fabricante // '',
            $nodo->obtener_precio // 0,
            $nodo->obtener_cantidad // 0,
            $nodo->obtener_fecha_ingreso // '',
            $nodo->obtener_nivel_minimo // 0
        ];
    }
}

# ====================== FILTRO AVANZADO AVL ======================

sub filtrar_avl_avanzado {
    my ($nodo, $arr, $criterio, $valor) = @_;
    return unless defined $nodo;

    filtrar_avl_avanzado($nodo->{izquierda}, $arr, $criterio, $valor);

    my $coincide = 0;

    if ($criterio eq "departamento" && $nodo->obtener_departamento eq $valor) {
        $coincide = 1;
    }
    elsif ($criterio eq "especialidad" && defined $nodo->obtener_especialidad && $nodo->obtener_especialidad eq $valor) {
        $coincide = 1;
    }
    elsif ($criterio eq "tipo" && $nodo->obtener_tipo eq $valor) {
        $coincide = 1;
    }

    if ($coincide) {
        push @$arr, [
            $nodo->obtener_numero_colegio // '',
            $nodo->obtener_nombre // '',
            $nodo->obtener_tipo // '',
            $nodo->obtener_especialidad // '',
            $nodo->obtener_departamento // ''
        ];
    }

    filtrar_avl_avanzado($nodo->{derecha}, $arr, $criterio, $valor);
}

# ====================== PANEL ADMIN GENERAL ====================== 

sub mostrar_panel_admin {
    my $win = Gtk3::Window->new('toplevel');
    $win->set_title("Panel Administrador General");
    $win->set_default_size(1100,650);

    my $notebook = Gtk3::Notebook->new();
    $win->add($notebook);

    # CARGA MASIVA
    my $box_carga = Gtk3::Box->new('vertical',10);
    my $btn_inv = Gtk3::Button->new("Cargar Inventario JSON");
    my $btn_usr = Gtk3::Button->new("Cargar Usuarios JSON");

    $box_carga->pack_start($btn_inv,FALSE,FALSE,15);
    $box_carga->pack_start($btn_usr,FALSE,FALSE,15);

    $notebook->append_page($box_carga, Gtk3::Label->new("Carga Masiva"));

    $btn_inv->signal_connect(clicked => sub { seleccionar_archivo("inventario"); });
    $btn_usr->signal_connect(clicked => sub { seleccionar_archivo("usuarios"); });

    # REGISTRO MANUAL
    my $box_reg = Gtk3::Box->new('vertical',15);
    $box_reg->set_border_width(20);

    my $lbl_reg = Gtk3::Label->new("<big><b>REGISTRO MANUAL (ADMIN GENERAL)</b></big>");
    $lbl_reg->set_use_markup(TRUE);
    $box_reg->pack_start($lbl_reg,FALSE,FALSE,10);

    # Registrar Medicamento
    my $frame_med = Gtk3::Frame->new("Registrar Medicamento");
    my $box_med = Gtk3::Box->new('vertical',8);
    $frame_med->add($box_med);

    my $entry_cod_med   = Gtk3::Entry->new(); $entry_cod_med->set_placeholder_text("Codigo");
    my $entry_nom_med   = Gtk3::Entry->new(); $entry_nom_med->set_placeholder_text("Nombre");
    my $entry_cant_med  = Gtk3::Entry->new(); $entry_cant_med->set_placeholder_text("Cantidad");
    my $entry_prec_med  = Gtk3::Entry->new(); $entry_prec_med->set_placeholder_text("Precio");
    my $btn_reg_med     = Gtk3::Button->new("Guardar Medicamento");

    $box_med->pack_start($entry_cod_med,FALSE,FALSE,5);
    $box_med->pack_start($entry_nom_med,FALSE,FALSE,5);
    $box_med->pack_start($entry_cant_med,FALSE,FALSE,5);
    $box_med->pack_start($entry_prec_med,FALSE,FALSE,5);
    $box_med->pack_start($btn_reg_med,FALSE,FALSE,10);

    $box_reg->pack_start($frame_med,FALSE,FALSE,15);

    # Registrar Usuario Departamental
    my $frame_pers = Gtk3::Frame->new("Registrar Usuario Departamental");
    my $box_pers = Gtk3::Box->new('vertical',8);
    $frame_pers->add($box_pers);

    my $entry_col = Gtk3::Entry->new(); $entry_col->set_placeholder_text("Numero de Colegio");
    my $entry_nom = Gtk3::Entry->new(); $entry_nom->set_placeholder_text("Nombre Completo");

    my $combo_tipo = Gtk3::ComboBoxText->new();
    $combo_tipo->append_text("TIPO-01");
    $combo_tipo->append_text("TIPO-02");
    $combo_tipo->append_text("TIPO-03");
    $combo_tipo->append_text("TIPO-04");
    $combo_tipo->append_text("TIPO-05");

    my $combo_dep = Gtk3::ComboBoxText->new();
    $combo_dep->append_text("DEP-ADM");
    $combo_dep->append_text("DEP-MED");
    $combo_dep->append_text("DEP-CIR");
    $combo_dep->append_text("DEP-LAB");
    $combo_dep->append_text("DEP-FAR");

    my $entry_esp = Gtk3::Entry->new(); $entry_esp->set_placeholder_text("Especialidad (solo TIPO-01 y TIPO-02)");

    my $entry_pass = Gtk3::Entry->new();
    $entry_pass->set_placeholder_text("Contrasena");
    $entry_pass->set_visibility(FALSE);

    my $btn_guardar = Gtk3::Button->new("Registrar Usuario");

    $box_pers->pack_start($entry_col,FALSE,FALSE,5);
    $box_pers->pack_start($entry_nom,FALSE,FALSE,5);
    $box_pers->pack_start($combo_tipo,FALSE,FALSE,5);
    $box_pers->pack_start($combo_dep,FALSE,FALSE,5);
    $box_pers->pack_start($entry_esp,FALSE,FALSE,5);
    $box_pers->pack_start($entry_pass,FALSE,FALSE,5);
    $box_pers->pack_start($btn_guardar,FALSE,FALSE,10);

    $box_reg->pack_start($frame_pers,FALSE,FALSE,15);

    $notebook->append_page($box_reg, Gtk3::Label->new("Registro"));

    $btn_reg_med->signal_connect(clicked => sub {
        my $cod  = $entry_cod_med->get_text();
        my $nom  = $entry_nom_med->get_text();
        my $cant = $entry_cant_med->get_text();
        my $prec = $entry_prec_med->get_text() || 0;

        if($cod && $nom && $cant){
            eval { $lista_medicamentos->insertar($cod, $nom, $cant, $prec, "SIN_PROV"); };
            my $msg = $@ ? "Error: $@" : "Medicamento registrado correctamente.";
            my $d = Gtk3::MessageDialog->new(undef,'modal','info','ok',$msg);
            $d->run; $d->destroy;
            $_->set_text("") for ($entry_cod_med, $entry_nom_med, $entry_cant_med, $entry_prec_med);
        } else {
            my $d = Gtk3::MessageDialog->new(undef,'modal','error','ok',"Faltan datos obligatorios.");
            $d->run; $d->destroy;
        }
    });

    $btn_guardar->signal_connect(clicked => sub {
        my $col  = $entry_col->get_text();
        my $nom  = $entry_nom->get_text();
        my $tipo = $combo_tipo->get_active_text();
        my $dep  = $combo_dep->get_active_text();
        my $esp  = $entry_esp->get_text();
        my $pass = $entry_pass->get_text();

        if(!$col || !$nom || !$tipo || !$dep || !$pass){
            my $d = Gtk3::MessageDialog->new(undef,'modal','error','ok',"Faltan datos obligatorios");
            $d->run; $d->destroy;
            return;
        }

        if(($tipo eq "TIPO-01" || $tipo eq "TIPO-02") && !$esp){
            my $d = Gtk3::MessageDialog->new(undef,'modal','error','ok',"Debe ingresar especialidad");
            $d->run; $d->destroy;
            return;
        }

        if(defined $avl_personal->buscar($col)){
            my $d = Gtk3::MessageDialog->new(undef,'modal','error','ok',"El usuario ya existe");
            $d->run; $d->destroy;
            return;
        }

        my $nuevo = NodoPersonal->new($col, $nom, $tipo, $dep, $esp, $pass);
        $avl_personal->insertar($nuevo);

        my $d = Gtk3::MessageDialog->new(undef,'modal','info','ok',"Usuario registrado correctamente");
        $d->run; $d->destroy;

        $_->set_text("") for ($entry_col,$entry_nom,$entry_esp,$entry_pass);
    });

    # REPORTES
    my $box_reportes = Gtk3::Box->new('vertical',10);
    my $btn_bst = Gtk3::Button->new("Reporte BST Equipos");
    my $btn_avl = Gtk3::Button->new("Reporte AVL Personal");
    my $btn_b   = Gtk3::Button->new("Reporte Arbol B");
    my $btn_matriz = Gtk3::Button->new("Reporte Matriz Proveedor-Fabricante");
    my $btn_inv_lista = Gtk3::Button->new("Reporte Inventario Medicamentos");
    my $btn_prov_lista = Gtk3::Button->new("Reporte Proveedores");

    $box_reportes->pack_start($btn_bst,FALSE,FALSE,8);
    $box_reportes->pack_start($btn_avl,FALSE,FALSE,8);
    $box_reportes->pack_start($btn_b,FALSE,FALSE,8);
    $box_reportes->pack_start($btn_matriz, FALSE, FALSE, 8);
    $box_reportes->pack_start($btn_inv_lista, FALSE, FALSE, 8);
    $box_reportes->pack_start($btn_prov_lista, FALSE, FALSE, 8);

    $notebook->append_page($box_reportes, Gtk3::Label->new("Reportes"));

    $btn_bst->signal_connect(clicked => sub {
        $bst_equipos->generar_dot("reports/bst_equipos.dot");
        system("dot -Tpng reports/bst_equipos.dot -o reports/bst_equipos.png");
        system("xdg-open reports/bst_equipos.png &");
    });

    $btn_avl->signal_connect(clicked => sub {
        $avl_personal->generar_dot("reports/avl_personal.dot");
        system("dot -Tpng reports/avl_personal.dot -o reports/avl_personal.png");
        system("xdg-open reports/avl_personal.png &");
    });

    $btn_b->signal_connect(clicked => sub {
        $btree_suministros->generar_dot("reports/arbol_b.dot");
        system("dot -Tpng reports/arbol_b.dot -o reports/arbol_b.png");
        system("xdg-open reports/arbol_b.png &");
    });
    $btn_matriz->signal_connect(clicked => sub {
    $matriz->generar_graphviz("reports/matriz.dot");
    system("dot -Tpng reports/matriz.dot -o reports/matriz.png");
    system("xdg-open reports/matriz.png &");
    });
    $btn_inv_lista->signal_connect(clicked => sub {
    $lista_medicamentos->generar_dot("reports/inventario.dot");
    system("dot -Tpng reports/inventario.dot -o reports/inventario.png");
    system("xdg-open reports/inventario.png &");
    });

    $btn_prov_lista->signal_connect(clicked => sub {
        $lista_proveedores->generar_dot("reports/proveedores.dot");
        system("dot -Tpng reports/proveedores.dot -o reports/proveedores.png");
        system("xdg-open reports/proveedores.png &");
    });

    # INFORMACION DEL SISTEMA
    my $box_info = Gtk3::Box->new('vertical',20);
    $box_info->set_border_width(30);

    my $lbl_info = Gtk3::Label->new();
    $lbl_info->set_markup(
        "<big><b>INFORMACION DEL SISTEMA</b></big>\n\n\n" .
        "<span size='large'>Adilzon Alfredo Velasquez Hernandez - 201908076</span>\n\n" .
        "<span size='large'>ESTRUCTURAS DE DATOS SECCION: C</span>"
    );
    $lbl_info->set_justify('center');

    $box_info->pack_start($lbl_info, TRUE, TRUE, 0);

    $notebook->append_page($box_info, Gtk3::Label->new("Informacion del sistema"));

    my $btn_logout = Gtk3::Button->new("Cerrar Sesion");
    my $btn_salir  = Gtk3::Button->new("Salir del Sistema");

    $box_info->pack_start($btn_logout,FALSE,FALSE,30);
    $box_info->pack_start($btn_salir,FALSE,FALSE,10);

    $btn_logout->signal_connect(clicked => sub { $win->destroy(); $win_login->show_all(); });
    $btn_salir->signal_connect(clicked => sub { Gtk3::main_quit(); });

    $win->show_all();
}
# ====================== PANEL TIPO-05 ======================

sub mostrar_panel_tipo5 {

    my $win = Gtk3::Window->new('toplevel');
    $win->set_title("Panel Administrador Departamental TIPO-05");
    $win->set_default_size(1250,720);

    my $notebook = Gtk3::Notebook->new();
    $win->add($notebook);

    # ====================== PERSONAL MEDICO (AVL) ======================
    my $box_personal = Gtk3::Box->new('vertical',10);
    $box_personal->set_border_width(15);

    my $lbl_pers = Gtk3::Label->new("<big><b>Personal Medico - Arbol AVL</b></big>");
    $lbl_pers->set_use_markup(TRUE);
    $box_personal->pack_start($lbl_pers, FALSE, FALSE, 10);

    my $btn_ver = Gtk3::Button->new("Ver Personal Completo");
    my $btn_filtrar = Gtk3::Button->new("Filtrar Personal");
    my $btn_avl_pre  = Gtk3::Button->new("AVL PreOrden");
    my $btn_avl_in   = Gtk3::Button->new("AVL InOrden");
    my $btn_avl_post = Gtk3::Button->new("AVL PostOrden");
    my $btn_reporte_avl = Gtk3::Button->new("Generar Reporte AVL");

    $box_personal->pack_start($btn_ver,FALSE,FALSE,8);
    $box_personal->pack_start($btn_filtrar,FALSE,FALSE,8);
    $box_personal->pack_start($btn_avl_pre,FALSE,FALSE,5);
    $box_personal->pack_start($btn_avl_in,FALSE,FALSE,5);
    $box_personal->pack_start($btn_avl_post,FALSE,FALSE,5);
    $box_personal->pack_start($btn_reporte_avl,FALSE,FALSE,8);

    $notebook->append_page($box_personal, Gtk3::Label->new("Personal Medico"));

    $btn_ver->signal_connect(clicked => sub {
        my @datos;
        obtener_datos_avl_tabla($avl_personal->{raiz}, \@datos);
        mostrar_tabla("Personal Medico Completo",
            ["Colegio","Nombre","Tipo","Especialidad","Departamento"],
            \@datos
        );
    });

    $btn_filtrar->signal_connect(clicked => sub {
        my $dialog = Gtk3::Dialog->new("Filtrar Personal", undef, 'modal', "OK" => "ok", "Cancelar" => "cancel");
        my $vbox = $dialog->get_content_area();

        my $lbl = Gtk3::Label->new("Selecciona el criterio de filtro:");
        $vbox->pack_start($lbl, FALSE, FALSE, 10);

        my $combo_criterio = Gtk3::ComboBoxText->new();
        $combo_criterio->append_text("Departamento");
        $combo_criterio->append_text("Especialidad");
        $combo_criterio->append_text("Tipo");
        $combo_criterio->set_active(0);
        $vbox->pack_start($combo_criterio, FALSE, FALSE, 5);

        my $entry_valor = Gtk3::Entry->new();
        $entry_valor->set_placeholder_text("Valor a buscar");
        $vbox->pack_start($entry_valor, FALSE, FALSE, 10);

        $dialog->show_all();

        if ($dialog->run eq "ok") {
            my $criterio_texto = $combo_criterio->get_active_text();
            my $valor = $entry_valor->get_text();

            if ($valor) {
                my $criterio = ($criterio_texto eq "Departamento") ? "departamento" :
                               ($criterio_texto eq "Especialidad") ? "especialidad" : "tipo";

                my @datos;
                filtrar_avl_avanzado($avl_personal->{raiz}, \@datos, $criterio, $valor);

                mostrar_tabla("Personal Filtrado",
                    ["Colegio","Nombre","Tipo","Especialidad","Departamento"],
                    \@datos
                );
            } else {
                my $d = Gtk3::MessageDialog->new(undef,'modal','error','ok',"Debe ingresar un valor.");
                $d->run; $d->destroy;
            }
        }
        $dialog->destroy();
    });

    $btn_avl_pre->signal_connect(clicked => sub {
        my @datos;
        recorrer_avl($avl_personal->{raiz}, \@datos, "pre");
        mostrar_tabla("AVL PreOrden", ["Colegio","Nombre","Tipo","Especialidad","Departamento"], \@datos);
    });

    $btn_avl_in->signal_connect(clicked => sub {
        my @datos;
        recorrer_avl($avl_personal->{raiz}, \@datos, "in");
        mostrar_tabla("AVL InOrden", ["Colegio","Nombre","Tipo","Especialidad","Departamento"], \@datos);
    });

    $btn_avl_post->signal_connect(clicked => sub {
        my @datos;
        recorrer_avl($avl_personal->{raiz}, \@datos, "post");
        mostrar_tabla("AVL PostOrden", ["Colegio","Nombre","Tipo","Especialidad","Departamento"], \@datos);
    });

    $btn_reporte_avl->signal_connect(clicked => sub {
        $avl_personal->generar_dot("reports/avl_personal.dot");
        system("dot -Tpng reports/avl_personal.dot -o reports/avl_personal.png");
        system("xdg-open reports/avl_personal.png &");
    });

    # ====================== PESTAÑA USUARIOS DEPARTAMENTALES ======================
    my $box_usuarios = Gtk3::Box->new('vertical', 20);
    $box_usuarios->set_border_width(30);

    my $lbl_usuarios = Gtk3::Label->new("<big><b>Usuarios Departamentales - Arbol AVL</b></big>");
    $lbl_usuarios->set_use_markup(TRUE);
    $box_usuarios->pack_start($lbl_usuarios, FALSE, FALSE, 20);

    my $btn_carga_masiva = Gtk3::Button->new("4.1 Carga Masiva de Usuarios Departamentales (JSON)");
    my $btn_registro     = Gtk3::Button->new("5. Registrar Usuario Departamental");
    my $btn_buscar       = Gtk3::Button->new("4.2 Buscar usuario por numero de colegio");
    my $btn_eliminar     = Gtk3::Button->new("4.3 Eliminar usuario del sistema");

    $btn_carga_masiva->set_size_request(450, 70);
    $btn_registro->set_size_request(450, 70);
    $btn_buscar->set_size_request(450, 70);
    $btn_eliminar->set_size_request(450, 70);

    $box_usuarios->pack_start($btn_carga_masiva, FALSE, FALSE, 15);
    $box_usuarios->pack_start($btn_registro,     FALSE, FALSE, 15);
    $box_usuarios->pack_start($btn_buscar,       FALSE, FALSE, 15);
    $box_usuarios->pack_start($btn_eliminar,     FALSE, FALSE, 15);

    $notebook->append_page($box_usuarios, Gtk3::Label->new("Usuarios Departamentales"));

    $btn_carga_masiva->signal_connect(clicked => sub { seleccionar_archivo_usuarios(); });
    $btn_registro->signal_connect(clicked => sub { registrar_usuario_departamental_dialog(); });
    $btn_buscar->signal_connect(clicked => sub { buscar_usuario_dialog(); });
    $btn_eliminar->signal_connect(clicked => sub { eliminar_usuario_dialog(); });

    # ====================== NUEVA PESTAÑA: CONSULTAR MATRIZ DISPERSA ======================
    my $box_matriz = Gtk3::Box->new('vertical', 20);
    $box_matriz->set_border_width(30);

    my $lbl_matriz = Gtk3::Label->new("<big><b>Consultar y Comparar Inventario por Proveedor/Fabricante (Matriz Dispersa)</b></big>");
    $lbl_matriz->set_use_markup(TRUE);
    $box_matriz->pack_start($lbl_matriz, FALSE, FALSE, 20);

    my $btn_ver_matriz = Gtk3::Button->new("Ver Matriz Dispersa Proveedor vs Fabricante");
    $btn_ver_matriz->set_size_request(450, 90);

    $box_matriz->pack_start($btn_ver_matriz, FALSE, FALSE, 40);

    $notebook->append_page($box_matriz, Gtk3::Label->new("Matriz Proveedor-Fabricante"));

    $btn_ver_matriz->signal_connect(clicked => sub {
        ver_matriz_dispersa();
    });

    # ====================== PESTAÑA INVENTARIO EQUIPOS BST ======================
    my $box_equipos = Gtk3::Box->new('vertical', 20);
    $box_equipos->set_border_width(30);

    my $lbl_equipos = Gtk3::Label->new("<big><b>Gestion de Inventario de Equipos Medicos (Arbol BST)</b></big>");
    $lbl_equipos->set_use_markup(TRUE);
    $box_equipos->pack_start($lbl_equipos, FALSE, FALSE, 20);

    my $btn_abrir_bst = Gtk3::Button->new("Abrir Menu de Gestion de Equipos Medicos");
    $btn_abrir_bst->set_size_request(450, 90);
    $btn_abrir_bst->override_background_color('normal', Gtk3::Gdk::RGBA->new(0.13, 0.55, 0.85, 1));
    $btn_abrir_bst->override_color('normal', Gtk3::Gdk::RGBA->new(1,1,1,1));

    $box_equipos->pack_start($btn_abrir_bst, FALSE, FALSE, 40);
    $notebook->append_page($box_equipos, Gtk3::Label->new("Inventario Equipos BST"));

    $btn_abrir_bst->signal_connect(clicked => sub { abrir_submenu_inventario_bst(); });

    # ====================== PESTAÑA INVENTARIO SUMINISTROS ARBOL B ======================
    my $box_suministros = Gtk3::Box->new('vertical', 20);
    $box_suministros->set_border_width(30);

    my $lbl_suministros = Gtk3::Label->new("<big><b>3. Gestion de Inventario de Suministros Medicos (Arbol B Orden 4)</b></big>");
    $lbl_suministros->set_use_markup(TRUE);
    $box_suministros->pack_start($lbl_suministros, FALSE, FALSE, 20);

    my $btn_abrir_b = Gtk3::Button->new("Abrir Menu de Gestion de Suministros Medicos");
    $btn_abrir_b->set_size_request(450, 90);
    $btn_abrir_b->override_background_color('normal', Gtk3::Gdk::RGBA->new(0.68, 0.16, 0.78, 1));
    $btn_abrir_b->override_color('normal', Gtk3::Gdk::RGBA->new(1,1,1,1));

    $box_suministros->pack_start($btn_abrir_b, FALSE, FALSE, 40);
    $notebook->append_page($box_suministros, Gtk3::Label->new("Inventario Suministros B"));

    $btn_abrir_b->signal_connect(clicked => sub { abrir_submenu_inventario_b(); });

    # Botones de salida
    my $btn_logout = Gtk3::Button->new("Cerrar Sesion");
    my $btn_salir  = Gtk3::Button->new("Salir del Sistema");

    $box_usuarios->pack_start($btn_logout, FALSE, FALSE, 40);
    $box_usuarios->pack_start($btn_salir,  FALSE, FALSE, 10);

    $btn_logout->signal_connect(clicked => sub { $win->destroy(); $win_login->show_all(); });
    $btn_salir->signal_connect(clicked => sub { Gtk3::main_quit(); });

    $win->show_all();
}

# ====================== SUBMENU BST ======================
sub abrir_submenu_inventario_bst {
    my $submenu = Gtk3::Window->new('toplevel');
    $submenu->set_title("Gestionar Inventario de Equipos Medicos");
    $submenu->set_default_size(520, 580);
    $submenu->set_border_width(25);
    $submenu->set_modal(TRUE);

    my $vbox = Gtk3::Box->new('vertical', 18);
    $submenu->add($vbox);

    my $titulo = Gtk3::Label->new("<big><b>2. Gestion de Inventario de Equipos Medicos</b></big>");
    $titulo->set_use_markup(TRUE);
    $vbox->pack_start($titulo, FALSE, FALSE, 15);

    my $btn1 = Gtk3::Button->new("2.1 Registrar equipo individual");
    my $btn2 = Gtk3::Button->new("2.2 Buscar equipo por codigo");
    my $btn3 = Gtk3::Button->new("2.3 Eliminar equipo del inventario");
    my $btn4 = Gtk3::Button->new("2.4 Visualizar inventario por recorridos");

    for my $btn ($btn1, $btn2, $btn3, $btn4) {
        $btn->set_size_request(420, 55);
        $vbox->pack_start($btn, FALSE, FALSE, 8);
    }

    my $btn_debug = Gtk3::Button->new("Ver todos los codigos registrados");
    $btn_debug->set_size_request(420, 50);
    $vbox->pack_start($btn_debug, FALSE, FALSE, 8);

    my $btn_cerrar = Gtk3::Button->new("Cerrar Submenu");
    $vbox->pack_start($btn_cerrar, FALSE, FALSE, 20);

    $submenu->show_all();

    $btn1->signal_connect(clicked => sub { registrar_equipo_dialog(); });
    $btn2->signal_connect(clicked => sub { buscar_equipo_dialog(); });
    $btn3->signal_connect(clicked => sub { eliminar_equipo_dialog(); });
    $btn4->signal_connect(clicked => sub { visualizar_recorridos_dialog(); });
    $btn_debug->signal_connect(clicked => sub { depurar_bst(); });

    $btn_cerrar->signal_connect(clicked => sub { $submenu->destroy(); });
}

# ====================== SUBMENU ARBOL B ======================
sub abrir_submenu_inventario_b {
    my $submenu = Gtk3::Window->new('toplevel');
    $submenu->set_title("3. Gestionar Inventario de Suministros Medicos (Arbol B)");
    $submenu->set_default_size(540, 620);
    $submenu->set_border_width(25);
    $submenu->set_modal(TRUE);

    my $vbox = Gtk3::Box->new('vertical', 18);
    $submenu->add($vbox);

    my $titulo = Gtk3::Label->new("<big><b>3. Gestion de Inventario de Suministros Medicos</b></big>");
    $titulo->set_use_markup(TRUE);
    $vbox->pack_start($titulo, FALSE, FALSE, 15);

    my $btn1 = Gtk3::Button->new("3.1 Registrar suministro individual");
    my $btn2 = Gtk3::Button->new("3.2 Buscar suministro por codigo");
    my $btn3 = Gtk3::Button->new("3.3 Eliminar suministro del inventario");
    my $btn4 = Gtk3::Button->new("3.4 Visualizar inventario por recorridos (InOrden)");

    for my $btn ($btn1, $btn2, $btn3, $btn4) {
        $btn->set_size_request(420, 55);
        $vbox->pack_start($btn, FALSE, FALSE, 8);
    }

    my $btn_debug = Gtk3::Button->new("Ver todos los suministros registrados");
    $btn_debug->set_size_request(420, 50);
    $vbox->pack_start($btn_debug, FALSE, FALSE, 8);

    my $btn_cerrar = Gtk3::Button->new("Cerrar Submenu");
    $vbox->pack_start($btn_cerrar, FALSE, FALSE, 20);

    $submenu->show_all();

    $btn1->signal_connect(clicked => sub { registrar_suministro_dialog(); });
    $btn2->signal_connect(clicked => sub { buscar_suministro_dialog(); });
    $btn3->signal_connect(clicked => sub { eliminar_suministro_dialog(); });
    $btn4->signal_connect(clicked => sub { visualizar_recorridos_b_dialog(); });
    $btn_debug->signal_connect(clicked => sub { depurar_arbol_b(); });

    $btn_cerrar->signal_connect(clicked => sub { $submenu->destroy(); });
}

# ====================== FUNCIONES DEL SUBMENU ======================

sub registrar_equipo_dialog {
    my $dialog = Gtk3::Dialog->new("Registrar Equipo Medico", undef, 'modal', "Guardar" => "ok", "Cancelar" => "cancel");
    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(12);
    $grid->set_column_spacing(15);
    $grid->set_border_width(20);

    my @labels = ("Codigo:", "Nombre:", "Fabricante:", "Precio Unitario:", "Cantidad:", "Fecha Ingreso (YYYY-MM-DD):", "Nivel Minimo:");
    my @entries;

    for my $i (0..6) {
        my $lbl = Gtk3::Label->new($labels[$i]);
        my $entry = Gtk3::Entry->new();
        $grid->attach($lbl, 0, $i, 1, 1);
        $grid->attach($entry, 1, $i, 1, 1);
        push @entries, $entry;
    }

    $dialog->get_content_area->add($grid);
    $dialog->show_all();

    if ($dialog->run eq "ok") {
        my ($cod, $nom, $fab, $prec, $cant, $fecha, $nmin) = map { $_->get_text() } @entries;

        if ($cod && $nom) {
            $cod =~ s/^\s+|\s+$//g;
            $cod = uc($cod);
            $cod =~ s/^EQU//i;
            $cod = "EQU-" . $cod if $cod !~ /^EQU-/i;

            eval {
                $bst_equipos->insertar_desde_datos($cod, $nom, $fab, $prec||0, $cant||0, $fecha, $nmin||0);
            };
            my $msg = $@ ? "Error: $@" : "Equipo registrado correctamente.";
            my $d = Gtk3::MessageDialog->new(undef,'modal','info','ok',$msg);
            $d->run; $d->destroy();
        } else {
            my $d = Gtk3::MessageDialog->new(undef,'modal','error','ok',"Codigo y Nombre son obligatorios.");
            $d->run; $d->destroy();
        }
    }
    $dialog->destroy();
}

sub buscar_equipo_dialog {
    my $dialog = Gtk3::Dialog->new("Buscar Equipo por Codigo", undef, 'modal', 
        "Buscar" => "ok", "Cancelar" => "cancel");

    my $entry = Gtk3::Entry->new();
    $entry->set_placeholder_text("Ingrese el codigo del equipo");
    $dialog->get_content_area->add($entry);
    $dialog->show_all();

    if ($dialog->run eq "ok") {
        my $cod = $entry->get_text();
        $cod =~ s/^\s+|\s+$//g;
        $cod = uc($cod);

        if ($cod) {
            my $equipo = $bst_equipos->buscar($cod);

            if (defined $equipo) {
                my $info = "EQUIPO ENCONTRADO\n\n" .
                            "Codigo: " . $equipo->obtener_codigo . "\n" .
                            "Nombre: " . $equipo->obtener_nombre . "\n" .
                            "Fabricante: " . $equipo->obtener_fabricante . "\n" .
                            "Precio: Q" . sprintf("%.2f", $equipo->obtener_precio) . "\n" .
                            "Cantidad: " . $equipo->obtener_cantidad . "\n" .
                            "Fecha Ingreso: " . $equipo->obtener_fecha_ingreso . "\n" .
                            "Nivel Minimo: " . $equipo->obtener_nivel_minimo;

                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok', $info);
                $d->run; $d->destroy();
            } else {
                my $msg = "No se encontro equipo con codigo '$cod'.\nUse el boton Ver todos los codigos registrados.";
                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok', $msg);
                $d->run; $d->destroy();
            }
        }
    }
    $dialog->destroy();
}

sub eliminar_equipo_dialog {
    my $dialog = Gtk3::Dialog->new("Eliminar Equipo", undef, 'modal', "Eliminar" => "ok", "Cancelar" => "cancel");
    my $entry = Gtk3::Entry->new();
    $entry->set_placeholder_text("Ingrese el codigo del equipo a eliminar");
    $dialog->get_content_area->add($entry);
    $dialog->show_all();

    if ($dialog->run eq "ok") {
        my $cod = $entry->get_text();
        $cod =~ s/^\s+|\s+$//g;
        $cod = uc($cod);

        if ($cod) {
            eval { $bst_equipos->eliminar($cod); };
            my $msg = $@ ? "Error: $@" : "Equipo eliminado correctamente.";
            my $d = Gtk3::MessageDialog->new(undef,'modal','info','ok',$msg);
            $d->run; $d->destroy();
        }
    }
    $dialog->destroy();
}

sub visualizar_recorridos_dialog {
    my $win = Gtk3::Window->new('toplevel');
    $win->set_title("Visualizar Inventario por Recorridos - BST");
    $win->set_default_size(1000, 650);
    $win->set_border_width(20);

    my $vbox = Gtk3::Box->new('vertical', 15);
    $win->add($vbox);

    my $lbl = Gtk3::Label->new();
    $lbl->set_markup("<big><b>2.4 Visualizar inventario por recorridos (Arbol BST)</b></big>");
    $vbox->pack_start($lbl, FALSE, FALSE, 10);

    my $btn_pre  = Gtk3::Button->new("PreOrden  (Raiz -> Izquierda -> Derecha)");
    my $btn_in   = Gtk3::Button->new("InOrden   (Izquierda -> Raiz -> Derecha)  <- Recomendado");
    my $btn_post = Gtk3::Button->new("PostOrden (Izquierda -> Derecha -> Raiz)");

    for my $btn ($btn_pre, $btn_in, $btn_post) {
        $btn->set_size_request(0, 60);
        $btn->override_font(Pango::FontDescription->from_string("Sans 11"));
    }

    $vbox->pack_start($btn_pre,  FALSE, FALSE, 8);
    $vbox->pack_start($btn_in,   FALSE, FALSE, 8);
    $vbox->pack_start($btn_post, FALSE, FALSE, 8);

    $btn_pre->signal_connect(clicked => sub {
        my @datos = ();
        recorrer_bst($bst_equipos->{raiz}, \@datos, "pre");

        if (@datos == 0) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
                "El arbol BST esta vacio.\nRegistre al menos un equipo primero.");
            $d->run; $d->destroy();
            return;
        }

        mostrar_tabla("BST - PreOrden", 
            ["Codigo","Nombre","Fabricante","Precio","Cantidad","Fecha Ingreso","Nivel Minimo"],
            \@datos);
    });

    $btn_in->signal_connect(clicked => sub {
        my @datos = ();
        recorrer_bst($bst_equipos->{raiz}, \@datos, "in");

        if (@datos == 0) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
                "El arbol BST esta vacio.\nRegistre al menos un equipo primero.");
            $d->run; $d->destroy();
            return;
        }

        mostrar_tabla("BST - InOrden (Ordenado por Codigo)", 
            ["Codigo","Nombre","Fabricante","Precio","Cantidad","Fecha Ingreso","Nivel Minimo"],
            \@datos);
    });

    $btn_post->signal_connect(clicked => sub {
        my @datos = ();
        recorrer_bst($bst_equipos->{raiz}, \@datos, "post");

        if (@datos == 0) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
                "El arbol BST esta vacio.\nRegistre al menos un equipo primero.");
            $d->run; $d->destroy();
            return;
        }

        mostrar_tabla("BST - PostOrden", 
            ["Codigo","Nombre","Fabricante","Precio","Cantidad","Fecha Ingreso","Nivel Minimo"],
            \@datos);
    });

    my $btn_cerrar = Gtk3::Button->new("Cerrar Ventana");
    $btn_cerrar->set_size_request(0, 45);
    $vbox->pack_start($btn_cerrar, FALSE, FALSE, 15);

    $btn_cerrar->signal_connect(clicked => sub { $win->destroy(); });

    $win->show_all();
}

sub depurar_bst {
    my @datos;
    recorrer_bst($bst_equipos->{raiz}, \@datos, "in");

    if (@datos == 0) {
        my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok', 
            "El inventario esta vacio.\nRegistra al menos un equipo primero.");
        $d->run; $d->destroy();
        return;
    }

    my $texto = "EQUIPOS REGISTRADOS ACTUALMENTE (" . scalar(@datos) . "):\n\n";
    foreach my $fila (@datos) {
        $texto .= "Codigo: $fila->[0]   |   Nombre: $fila->[1]\n";
    }

    my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok', $texto);
    $d->run; $d->destroy();
}

# ====================== FUNCIONES ARBOL B ======================

sub registrar_suministro_dialog {
    my $dialog = Gtk3::Dialog->new(
        "Registrar Suministro Medico", 
        undef, 
        'modal', 
        "Guardar" => 'ok', 
        "Cancelar" => 'cancel'
    );

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(12);
    $grid->set_column_spacing(15);
    $grid->set_border_width(20);

    my @labels = ("Codigo:", "Nombre:", "Fabricante:", "Precio Unitario:", 
                  "Cantidad:", "Fecha Vencimiento (YYYY-MM-DD):", "Nivel Minimo:");
    my @entries;

    for my $i (0 .. 6) {
        my $lbl = Gtk3::Label->new($labels[$i]);
        my $entry = Gtk3::Entry->new();
        $grid->attach($lbl,   0, $i, 1, 1);
        $grid->attach($entry, 1, $i, 1, 1);
        push @entries, $entry;
    }

    $dialog->get_content_area()->add($grid);
    $dialog->show_all();

    if ($dialog->run() eq 'ok') {
        my ($cod, $nom, $fab, $prec, $cant, $fecha_venc, $nmin) = 
            map { $_->get_text() // '' } @entries;

        $cod = uc($cod);
        $cod =~ s/^\s+|\s+$//g;
        $nom =~ s/^\s+|\s+$//g;

        if (!$cod || !$nom) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
                "Codigo y Nombre son obligatorios.");
            $d->run(); $d->destroy();
        } else {
            eval {
                my $nuevo_suministro = NodoSuministro->new(
                    $cod, 
                    $nom, 
                    $fab || 'Sin fabricante', 
                    $prec || 0, 
                    $cant || 0, 
                    $fecha_venc || '', 
                    $nmin || 0
                );

                $btree_suministros->insertar($nuevo_suministro);
            };

            if ($@) {
                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
                    "Error al registrar:\n$@");
                $d->run(); $d->destroy();
            } else {
                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
                    "Suministro '$cod - $nom' registrado correctamente.");
                $d->run(); $d->destroy();
            }
        }
    }
    $dialog->destroy();
}

sub buscar_suministro_dialog {
    my $dialog = Gtk3::Dialog->new("Buscar Suministro por Codigo", undef, 'modal', "Buscar" => "ok", "Cancelar" => "cancel");

    my $entry = Gtk3::Entry->new();
    $entry->set_placeholder_text("Ingrese el codigo del suministro");
    $dialog->get_content_area->add($entry);
    $dialog->show_all();

    if ($dialog->run eq "ok") {
        my $cod = uc($entry->get_text());
        if ($cod) {
            my $suministro = $btree_suministros->buscar($cod);
            if (defined $suministro) {
                my $info = "SUMINISTRO ENCONTRADO\n\n" .
                            "Codigo: " . ($suministro->obtener_codigo // '') . "\n" .
                            "Nombre: " . ($suministro->obtener_nombre // '') . "\n" .
                            "Fabricante: " . ($suministro->obtener_fabricante // '') . "\n" .
                            "Precio: Q" . sprintf("%.2f", ($suministro->obtener_precio // 0)) . "\n" .
                            "Cantidad: " . ($suministro->obtener_cantidad // 0) . "\n" .
                            "Fecha Vencimiento: " . ($suministro->obtener_fecha_vencimiento // 'N/A') . "\n" .
                            "Nivel Minimo: " . ($suministro->obtener_nivel_minimo // 0);

                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok', $info);
                $d->run; $d->destroy();
            } else {
                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok', "No se encontro suministro con codigo '$cod'.");
                $d->run; $d->destroy();
            }
        }
    }
    $dialog->destroy();
}

sub eliminar_suministro_dialog {
    my $dialog = Gtk3::Dialog->new("Eliminar Suministro", undef, 'modal', "Eliminar" => "ok", "Cancelar" => "cancel");
    my $entry = Gtk3::Entry->new();
    $entry->set_placeholder_text("Ingrese el codigo del suministro a eliminar");
    $dialog->get_content_area->add($entry);
    $dialog->show_all();

    if ($dialog->run eq "ok") {
        my $cod = uc($entry->get_text());
        if ($cod) {
            eval { $btree_suministros->eliminar($cod); };
            my $msg = $@ ? "Error: $@" : "Suministro eliminado correctamente.";
            my $d = Gtk3::MessageDialog->new(undef,'modal','info','ok',$msg);
            $d->run; $d->destroy();
        }
    }
    $dialog->destroy();
}

# ====================== RECOLECTAR INORDEN ARBOL B ======================
sub recolectar_inorden_b {
    my ($nodo, $arr) = @_;
    return unless defined $nodo;

    for (my $i = 0; $i < @{$nodo->{claves}}; $i++) {
        recolectar_inorden_b($nodo->{hijos}[$i], $arr) if $i < @{$nodo->{hijos}};
        my $s = $nodo->{claves}[$i];
        push @$arr, [
            $s->obtener_codigo // '',
            $s->obtener_nombre // '',
            $s->obtener_fabricante // '',
            $s->obtener_precio // 0,
            $s->obtener_cantidad // 0,
            $s->obtener_fecha_vencimiento // '',
            $s->obtener_nivel_minimo // 0
        ];
    }

    recolectar_inorden_b($nodo->{hijos}[$#{$nodo->{hijos}}], $arr) 
        if @{$nodo->{hijos}} > @{$nodo->{claves}};
}

sub depurar_arbol_b {
    my @datos = ();
    recolectar_inorden_b($btree_suministros->{raiz}, \@datos);

    if (@datos == 0) {
        my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
            "No hay suministros registrados en el Arbol B.");
        $d->run();
        $d->destroy();
        return;
    }

    my $texto = "SUMINISTROS REGISTRADOS (" . scalar(@datos) . "):\n\n";
    foreach my $fila (@datos) {
        $texto .= "Codigo: " . $fila->[0] . "   |   Nombre: " . $fila->[1] . "\n";
    }

    my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok', $texto);
    $d->run();
    $d->destroy();
}

sub visualizar_recorridos_b_dialog {
    my $win = Gtk3::Window->new('toplevel');
    $win->set_title("Visualizar Suministros - Arbol B");
    $win->set_default_size(950, 600);

    my $vbox = Gtk3::Box->new('vertical', 15);
    $win->add($vbox);

    my $lbl = Gtk3::Label->new();
    $lbl->set_markup("<big><b>3.4 Visualizar inventario de suministros (InOrden)</b></big>");
    $vbox->pack_start($lbl, FALSE, FALSE, 15);

    my $btn_in = Gtk3::Button->new("Mostrar InOrden (Ordenado por Codigo)");
    $btn_in->set_size_request(0, 60);
    $vbox->pack_start($btn_in, FALSE, FALSE, 20);

    $btn_in->signal_connect(clicked => sub {
        my @datos = ();
        recolectar_inorden_b($btree_suministros->{raiz}, \@datos);

        if (@datos == 0) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
                "El Arbol B de suministros esta vacio.");
            $d->run();
            $d->destroy();
            return;
        }

        mostrar_tabla("Arbol B - InOrden",
            ["Codigo","Nombre","Fabricante","Precio","Cantidad","Fecha Vencimiento","Nivel Minimo"],
            \@datos);
    });

    my $btn_cerrar = Gtk3::Button->new("Cerrar Ventana");
    $vbox->pack_start($btn_cerrar, FALSE, FALSE, 15);
    $btn_cerrar->signal_connect(clicked => sub { $win->destroy(); });

    $win->show_all();
}


# ====================== VER MATRIZ DISPERSA ======================
sub ver_matriz_dispersa {
    # Intentamos obtener los datos de la forma mas segura posible
    my @datos = ();

    eval {
        # Si tu matriz tiene un metodo para listar todo, usalo
        if ($matriz->can('obtener_todo') || $matriz->can('get_all') || $matriz->can('to_array')) {
            @datos = $matriz->obtener_todo() if $matriz->can('obtener_todo');
            @datos = $matriz->get_all()     if $matriz->can('get_all');
            @datos = $matriz->to_array()    if $matriz->can('to_array');
        }
        # Si no tiene ningun metodo, mostramos un mensaje claro
        else {
            die "La matriz no tiene metodo para extraer datos.\n";
        }
    };

    if ($@ || @datos == 0) {
        my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
            "La matriz dispersa esta vacia o no tiene metodo para mostrar datos.\n\n" .
            "Realice primero una carga masiva de inventario para llenar la matriz.");
        $d->run();
        $d->destroy();
        return;
    }

    mostrar_tabla("Matriz Dispersa - Proveedor vs Fabricante",
        ["Proveedor", "Fabricante", "Cantidad Total Productos"],
        \@datos);
}

# ====================== FUNCIONES AUXILIARES ======================

sub obtener_datos_avl_tabla {
    my ($nodo, $arr) = @_;
    return unless defined $nodo;

    obtener_datos_avl_tabla($nodo->{izquierda}, $arr);

    push @$arr, [
        $nodo->obtener_numero_colegio // '',
        $nodo->obtener_nombre // '',
        $nodo->obtener_tipo // '',
        $nodo->obtener_especialidad // '',
        $nodo->obtener_departamento // ''
    ];

    obtener_datos_avl_tabla($nodo->{derecha}, $arr);
}

# ====================== CONTROL DE PERMISOS ======================
sub tiene_permiso {
    my ($usuario, $modulo) = @_;

    my $tipo = $usuario->obtener_tipo();
    my $dep  = $usuario->obtener_departamento();

    # DEP-ADM → acceso total
    return 1 if $dep eq "DEP-ADM";

    # DEP-MED → medicamentos y suministros
    if ($dep eq "DEP-MED") {
        return 1 if $modulo eq "medicamentos" || $modulo eq "suministros";
    }

    # DEP-CIR → equipos y suministros
    if ($dep eq "DEP-CIR") {
        return 1 if $modulo eq "equipos" || $modulo eq "suministros";
    }

    # DEP-LAB → solo equipos
    if ($dep eq "DEP-LAB") {
        return 1 if $modulo eq "equipos";
    }

    # DEP-FAR → solo medicamentos
    if ($dep eq "DEP-FAR") {
        return 1 if $modulo eq "medicamentos";
    }

    return 0;
}

# ====================== FUNCIONES PARA USUARIO MEDICO ======================

sub consultar_medicamentos_dialog {
    my $dialog = Gtk3::Dialog->new("Consultar Disponibilidad de Medicamentos", undef, 'modal', "Buscar" => "ok", "Cancelar" => "cancel");

    my $entry = Gtk3::Entry->new();
    $entry->set_placeholder_text("Ingrese codigo del medicamento");
    $dialog->get_content_area->add($entry);
    $dialog->show_all();

    if ($dialog->run eq "ok") {
        my $cod = uc($entry->get_text());
        $cod =~ s/^\s+|\s+$//g;

        if ($cod) {
            my $med = $lista_medicamentos->buscar($cod);

            if (defined $med) {
                my $info = "MEDICAMENTO ENCONTRADO\n\n" .
                           "Codigo: " . ($med->obtener_codigo // '') . "\n" .
                           "Nombre: " . ($med->obtener_nombre // '') . "\n" .
                           "Cantidad: " . ($med->obtener_cantidad // 0) . "\n" .
                           "Precio: Q" . sprintf("%.2f", ($med->obtener_precio // 0)) . "\n" .
                           "Fecha Vencimiento: " . ($med->obtener_fecha_vencimiento // 'N/A');

                if (($med->obtener_cantidad // 0) < ($med->obtener_nivel_minimo // 0)) {
                    $info .= "\n\nALERTA: Stock bajo el nivel minimo!";
                }

                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok', $info);
                $d->run; $d->destroy();
            } else {
                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok', "No se encontro medicamento con codigo '$cod'.");
                $d->run; $d->destroy();
            }
        }
    }
    $dialog->destroy();
}

sub perfil_usuario_dialog {
    my $dialog = Gtk3::Dialog->new("Perfil de Usuario", undef, 'modal', "Guardar Cambios" => "ok", "Cancelar" => "cancel");

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(12);
    $grid->set_column_spacing(15);
    $grid->set_border_width(20);

    my $nodo = $usuario_actual;

    my $lbl_col = Gtk3::Label->new("Numero de Colegio: " . ($nodo->obtener_numero_colegio // ''));
    $grid->attach($lbl_col, 0, 0, 2, 1);

    my $entry_nom = Gtk3::Entry->new();
    $entry_nom->set_text($nodo->obtener_nombre // '');
    $grid->attach(Gtk3::Label->new("Nombre Completo:"), 0, 1, 1, 1);
    $grid->attach($entry_nom, 1, 1, 1, 1);

    my $entry_pass = Gtk3::Entry->new();
    $entry_pass->set_visibility(FALSE);
    $entry_pass->set_text($nodo->obtener_contrasena // '');
    $grid->attach(Gtk3::Label->new("Nueva Contrasena:"), 0, 2, 1, 1);
    $grid->attach($entry_pass, 1, 2, 1, 1);

    $dialog->get_content_area()->add($grid);
    $dialog->show_all();

    if ($dialog->run eq 'ok') {
        my $new_nom = $entry_nom->get_text();
        my $new_pass = $entry_pass->get_text();

        if ($new_nom) {
            $nodo->{nombre} = $new_nom;
            if ($new_pass) {
                $nodo->{contrasena} = $new_pass;
            }
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok', "Perfil actualizado correctamente.");
            $d->run; $d->destroy();
        }
    }
    $dialog->destroy();
}

# ====================== PANEL USUARIO NORMAL ======================

sub mostrar_panel_usuario {
    my $win = Gtk3::Window->new('toplevel');
    $win->set_title("Panel Usuario Medico");
    $win->set_default_size(1100,650);

    my $notebook = Gtk3::Notebook->new();
    $win->add($notebook);

    # Home
    my $box_home = Gtk3::Box->new('vertical',20);
    $box_home->set_border_width(30);

    my $nombre = eval { $usuario_actual->obtener_nombre() } || "Usuario";
    my $lbl_home = Gtk3::Label->new("<big><b>Bienvenido, $nombre</b></big>");
    $lbl_home->set_use_markup(TRUE);
    $box_home->pack_start($lbl_home, FALSE, FALSE, 20);

    $notebook->append_page($box_home, Gtk3::Label->new("Inicio"));

    # Medicamentos
    my $box_med = Gtk3::Box->new('vertical',20);
    $box_med->set_border_width(30);
    my $btn_med = Gtk3::Button->new("2. Consultar Disponibilidad de Medicamentos (Lista Doblemente Enlazada)");
    $btn_med->set_size_request(0,60);
    $box_med->pack_start($btn_med, FALSE, FALSE, 20);
    $notebook->append_page($box_med, Gtk3::Label->new("Medicamentos"));
    $btn_med->signal_connect(clicked => sub {
    if (tiene_permiso($usuario_actual, "medicamentos")) {
        consultar_medicamentos_dialog();
    } else {
        my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
            "No tienes permiso para acceder a Medicamentos.");
        $d->run; $d->destroy();
    }
});

    # Equipos
    my $box_eq = Gtk3::Box->new('vertical',20);
    $box_eq->set_border_width(30);
    my $btn_eq = Gtk3::Button->new("3. Consultar Disponibilidad de Equipos Medicos (Arbol BST)");
    $btn_eq->set_size_request(0,60);
    $box_eq->pack_start($btn_eq, FALSE, FALSE, 20);
    $notebook->append_page($box_eq, Gtk3::Label->new("Equipos"));
    $btn_eq->signal_connect(clicked => sub {
    if (tiene_permiso($usuario_actual, "equipos")) {
        buscar_equipo_dialog();
    } else {
        my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
            "No tienes permiso para acceder a Equipos.");
        $d->run; $d->destroy();
    }
});

    # Suministros
    my $box_sum = Gtk3::Box->new('vertical',20);
    $box_sum->set_border_width(30);
    my $btn_sum = Gtk3::Button->new("4. Consultar Disponibilidad de Suministros (Arbol B)");
    $btn_sum->set_size_request(0,60);
    $box_sum->pack_start($btn_sum, FALSE, FALSE, 20);
    $notebook->append_page($box_sum, Gtk3::Label->new("Suministros"));
    $btn_sum->signal_connect(clicked => sub {
    if (tiene_permiso($usuario_actual, "suministros")) {
        buscar_suministro_dialog();
    } else {
        my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
            "No tienes permiso para acceder a Suministros.");
        $d->run; $d->destroy();
    }
});

    # Perfil
    my $box_perfil = Gtk3::Box->new('vertical',20);
    $box_perfil->set_border_width(30);
    my $btn_perfil = Gtk3::Button->new("5. Perfil de Usuario");
    $btn_perfil->set_size_request(0,60);
    $box_perfil->pack_start($btn_perfil, FALSE, FALSE, 20);
    $notebook->append_page($box_perfil, Gtk3::Label->new("Mi Perfil"));
    $btn_perfil->signal_connect(clicked => sub { perfil_usuario_dialog(); });

    # Logout
    my $btn_logout = Gtk3::Button->new("Cerrar Sesion");
    my $btn_salir  = Gtk3::Button->new("Salir del Sistema");

    $box_home->pack_start($btn_logout, FALSE, FALSE, 40);
    $box_home->pack_start($btn_salir,  FALSE, FALSE, 10);

    $btn_logout->signal_connect(clicked => sub { $win->destroy(); $win_login->show_all(); });
    $btn_salir->signal_connect(clicked => sub { Gtk3::main_quit(); });

    $win->show_all();
}

# ====================== FILE CHOOSER ======================

sub seleccionar_archivo {
    my $tipo = shift;

    my $dialog = Gtk3::FileChooserDialog->new(
        "Seleccionar JSON", undef, "open",
        "Cancelar","cancel", "Abrir","accept"
    );

    $dialog->set_current_folder("data");

    if($dialog->run eq "accept")
    {
        my $archivo = $dialog->get_filename();

        if($tipo eq "inventario")
        {
            CargaJSON::cargar_inventario(
                $archivo,
                $lista_medicamentos,
                $bst_equipos,
                $btree_suministros,
                $lista_proveedores,
                $matriz
            );
        }
        else
        {
            CargaJSON::cargar_usuarios($archivo,$avl_personal);
        }
    }

    $dialog->destroy();
}

# ====================== 4.1 CARGA MASIVA DE USUARIOS ======================
sub seleccionar_archivo_usuarios {
    my $dialog = Gtk3::FileChooserDialog->new(
        "Seleccionar JSON de Usuarios Departamentales", 
        undef, 
        "open",
        "Cancelar","cancel", 
        "Abrir","accept"
    );

    $dialog->set_current_folder("data");

    if ($dialog->run eq "accept") {
        my $archivo = $dialog->get_filename();

        eval {
            CargaJSON::cargar_usuarios($archivo, $avl_personal);
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
                "Carga masiva de usuarios departamentales completada correctamente.");
            $d->run();
            $d->destroy();
        };

        if ($@) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
                "Error durante la carga masiva:\n$@");
            $d->run();
            $d->destroy();
        }
    }

    $dialog->destroy();
}

# ====================== 5. REGISTRAR USUARIO DEPARTAMENTAL ======================
sub registrar_usuario_departamental_dialog {
    my $dialog = Gtk3::Dialog->new(
        "Registrar Usuario Departamental", 
        undef, 
        'modal', 
        "Guardar" => 'ok', 
        "Cancelar" => 'cancel'
    );

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(12);
    $grid->set_column_spacing(15);
    $grid->set_border_width(20);

    my @labels = (
        "Numero de Colegio:",
        "Nombre Completo:",
        "Tipo de Usuario:",
        "Departamento:",
        "Especialidad (solo TIPO-01 y TIPO-02):",
        "Contrasena:"
    );

    my $entry_col = Gtk3::Entry->new();
    $grid->attach(Gtk3::Label->new($labels[0]), 0, 0, 1, 1);
    $grid->attach($entry_col, 1, 0, 1, 1);

    my $entry_nom = Gtk3::Entry->new();
    $grid->attach(Gtk3::Label->new($labels[1]), 0, 1, 1, 1);
    $grid->attach($entry_nom, 1, 1, 1, 1);

    my $combo_tipo = Gtk3::ComboBoxText->new();
    $combo_tipo->append_text("TIPO-01");
    $combo_tipo->append_text("TIPO-02");
    $combo_tipo->append_text("TIPO-03");
    $combo_tipo->append_text("TIPO-04");
    $combo_tipo->set_active(0);
    $grid->attach(Gtk3::Label->new($labels[2]), 0, 2, 1, 1);
    $grid->attach($combo_tipo, 1, 2, 1, 1);

    my $combo_dep = Gtk3::ComboBoxText->new();
    $combo_dep->append_text("DEP-ADM");
    $combo_dep->append_text("DEP-MED");
    $combo_dep->append_text("DEP-CIR");
    $combo_dep->append_text("DEP-LAB");
    $combo_dep->append_text("DEP-FAR");
    $combo_dep->set_active(0);
    $grid->attach(Gtk3::Label->new($labels[3]), 0, 3, 1, 1);
    $grid->attach($combo_dep, 1, 3, 1, 1);

    my $entry_esp = Gtk3::Entry->new();
    $grid->attach(Gtk3::Label->new($labels[4]), 0, 4, 1, 1);
    $grid->attach($entry_esp, 1, 4, 1, 1);

    my $entry_pass = Gtk3::Entry->new();
    $entry_pass->set_visibility(FALSE);
    $grid->attach(Gtk3::Label->new($labels[5]), 0, 5, 1, 1);
    $grid->attach($entry_pass, 1, 5, 1, 1);

    $dialog->get_content_area()->add($grid);
    $dialog->show_all();

    if ($dialog->run() eq 'ok') {
        my $col  = $entry_col->get_text();
        my $nom  = $entry_nom->get_text();
        my $tipo = $combo_tipo->get_active_text();
        my $dep  = $combo_dep->get_active_text();
        my $esp  = $entry_esp->get_text();
        my $pass = $entry_pass->get_text();

        $col =~ s/^\s+|\s+$//g;

        if (!$col || !$nom || !$tipo || !$dep || !$pass) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
                "Todos los campos son obligatorios.");
            $d->run(); $d->destroy();
            $dialog->destroy();
            return;
        }

        if (($tipo eq "TIPO-01" || $tipo eq "TIPO-02") && !$esp) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
                "La especialidad es obligatoria para TIPO-01 y TIPO-02.");
            $d->run(); $d->destroy();
            $dialog->destroy();
            return;
        }

        if (defined $avl_personal->buscar($col)) {
            my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
                "El numero de colegio $col ya esta registrado.");
            $d->run(); $d->destroy();
        } else {
            eval {
                my $nuevo = NodoPersonal->new($col, $nom, $tipo, $dep, $esp, $pass);
                $avl_personal->insertar($nuevo);
            };

            if ($@) {
                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
                    "Error al registrar usuario:\n$@");
                $d->run(); $d->destroy();
            } else {
                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok',
                    "Usuario $col registrado correctamente en el Arbol AVL.");
                $d->run(); $d->destroy();
            }
        }
    }

    $dialog->destroy();
}

# ====================== 4.2 BUSCAR USUARIO ======================
sub buscar_usuario_dialog {
    my $dialog = Gtk3::Dialog->new("Buscar Usuario por Numero de Colegio", undef, 'modal', 
        "Buscar" => "ok", "Cancelar" => "cancel");

    my $entry = Gtk3::Entry->new();
    $entry->set_placeholder_text("Ingrese el numero de colegio");
    $dialog->get_content_area->add($entry);
    $dialog->show_all();

    if ($dialog->run eq "ok") {
        my $col = $entry->get_text();
        $col =~ s/^\s+|\s+$//g;

        if ($col) {
            my $usuario = $avl_personal->buscar($col);

            if (defined $usuario) {
                my $info = "USUARIO ENCONTRADO\n\n" .
                           "Numero de Colegio: " . ($usuario->obtener_numero_colegio // '') . "\n" .
                           "Nombre: " . ($usuario->obtener_nombre // '') . "\n" .
                           "Tipo: " . ($usuario->obtener_tipo // '') . "\n" .
                           "Departamento: " . ($usuario->obtener_departamento // '') . "\n" .
                           "Especialidad: " . ($usuario->obtener_especialidad // 'No aplica') . "\n" .
                           "Contrasena: " . ($usuario->obtener_contrasena // '');

                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'info', 'ok', $info);
                $d->run; $d->destroy();
            } else {
                my $d = Gtk3::MessageDialog->new(undef, 'modal', 'error', 'ok',
                    "No se encontro usuario con numero de colegio '$col'.");
                $d->run; $d->destroy();
            }
        }
    }
    $dialog->destroy();
}

# ====================== 4.3 ELIMINAR USUARIO ======================
sub eliminar_usuario_dialog {
    my $dialog = Gtk3::Dialog->new("Eliminar Usuario", undef, 'modal', 
        "Eliminar" => "ok", "Cancelar" => "cancel");

    my $entry = Gtk3::Entry->new();
    $entry->set_placeholder_text("Ingrese el numero de colegio a eliminar");
    $dialog->get_content_area->add($entry);
    $dialog->show_all();

    if ($dialog->run eq "ok") {
        my $col = $entry->get_text();
        $col =~ s/^\s+|\s+$//g;

        if ($col) {
            if (defined $avl_personal->buscar($col)) {
                eval { $avl_personal->eliminar($col); };
                my $msg = $@ ? "Error: $@" : "Usuario eliminado correctamente del Arbol AVL.";
                my $d = Gtk3::MessageDialog->new(undef,'modal','info','ok',$msg);
                $d->run; $d->destroy();
            } else {
                my $d = Gtk3::MessageDialog->new(undef,'modal','error','ok',
                    "No se encontro usuario con numero de colegio '$col'.");
                $d->run; $d->destroy();
            }
        }
    }
    $dialog->destroy();
}

# ====================== START ======================

$win_login->show_all();
Gtk3::main();