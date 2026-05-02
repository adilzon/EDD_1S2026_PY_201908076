#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use strict;
use warnings;
use utf8;

# Cargar librerías
use lib 'lib';
use JSON qw(decode_json);

use Model::ArbolAVL;
use Model::TablaHash;
use Model::GrafoNoDirigido;

print "Iniciando MedTrack Fase 3...\n";

# ==================== CONFIGURACIÓN ====================
app->secrets(['MedTrack2026Fase3Secret']);
app->renderer->paths(['templates']);

# Variables globales
my $avl_usuarios = undef;
my $tabla_hash   = undef;
my $grafo_red    = undef;

# Helper para inicializar estructuras
helper init_system => sub ($c) {
    if (!defined $avl_usuarios) {
        $avl_usuarios = Model::ArbolAVL->new();
        $tabla_hash   = Model::TablaHash->new();
        $grafo_red    = Model::GrafoNoDirigido->new();
        print "✅ AVL, Tabla Hash y Grafo inicializados correctamente\n";
    }
    return ($avl_usuarios, $tabla_hash, $grafo_red);
};

# ==================== RUTAS ====================

get '/' => sub ($c) {
    $c->render(template => 'index');
};

get '/saludo' => sub ($c) {
    $c->render(json => { mensaje => 'MedTrack Fase 3 funcionando' });
};

get '/status' => sub ($c) {
    my ($avl, $hash) = $c->init_system();
    $c->render(json => {
        status     => 'running',
        mensaje    => 'Sistema activo',
        tabla_hash => $hash->estado()
    });
};

# ==================== CARGA MASIVA DE USUARIOS (VERSIÓN SEGURA) ====================
post '/admin/cargar_usuarios' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();

    my $ruta_json = 'data/usuarios_departamentales.json';

    if (! -e $ruta_json) {
        return $c->render(json => { success => \0, error => "Archivo no encontrado" });
    }

    my $json_text = do { local (@ARGV, $/) = $ruta_json; <> };
    my $data = decode_json($json_text);

    my $contador = 0;
    my $errores  = 0;
    my $detalles = [];

    foreach my $u (@{$data->{usuarios} || []}) {
        next unless $u && $u->{numero_colegio};

        eval {
            my $depto = $u->{departamento};
            $depto = 'PENDIENTE' if !defined $depto || $depto eq '' || $depto eq 'null';

            # Llamada segura al constructor
            my $usuario_obj = Model::NodoPersonal->new(
                $u->{numero_colegio},
                $u->{nombre_completo} || 'Sin Nombre',
                $u->{tipo_usuario}    || 'TIPO-01',
                $depto,
                $u->{especialidad}    || 'N/A',
                $u->{contrasena}      || 'medtrack2026'
            );

            if (defined $usuario_obj) {
                $avl->insertar($usuario_obj);
                $tabla->insertar($usuario_obj);
                $grafo->insertar_vertice($u->{numero_colegio}, $u->{nombre_completo}, $depto);
                $contador++;
            } else {
                die "new() devolvió undef";
            }
        } or do {
            $errores++;
            push @$detalles, {
                numero_colegio => $u->{numero_colegio},
                error => substr($@ || 'Error desconocido en new()', 0, 250)
            };
        };
    }

    $c->render(json => {
        success           => \1,
        mensaje           => "Carga masiva completada",
        usuarios_cargados => $contador,
        errores           => $errores,
        detalles_errores  => $detalles,
        tabla_hash        => $tabla->estado()
    });
};

# ==================== RUTAS DE ASIGNACIÓN DE DEPARTAMENTO ====================

get '/admin/usuarios_pendientes' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();
    my @pendientes;
    
    # Recorremos el grafo (que tiene a todos los usuarios registrados)
    foreach my $id (keys %{$grafo->{departamentos}}) {
        if ($grafo->{departamentos}{$id} eq 'PENDIENTE') {
            push @pendientes, {
                numero_colegio  => $id,
                nombre_completo => $grafo->{nombres}{$id}
            };
        }
    }
    
    $c->render(json => { pendientes => \@pendientes });
};

post '/admin/asignar_departamento' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();
    my $json = $c->req->json;
    
    my $id = $json->{numero_colegio};
    my $depto = $json->{departamento};
    
    if (!$id || !$depto) {
        return $c->render(json => { success => \0, error => "Faltan datos" });
    }
    
    # Actualizamos el grafo (la representación rápida de usuarios)
    if (exists $grafo->{departamentos}{$id}) {
        $grafo->{departamentos}{$id} = $depto;
        # Nota: Idealmente también se actualizaría en el AVL y Hash
        return $c->render(json => { success => \1, mensaje => "Departamento asignado" });
    }
    
    $c->render(json => { success => \0, error => "Usuario no encontrado" });
};

# ==================== RUTAS DE RED DE COLABORACIÓN (GRAFO) ====================

post '/admin/red/colaboracion' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();
    my $json = $c->req->json;
    
    my $id1 = $json->{usuario1};
    my $id2 = $json->{usuario2};
    
    if (!$id1 || !$id2) {
        return $c->render(json => { error => "Faltan IDs de usuarios", success => \0 });
    }
    
    $grafo->insertar_arista($id1, $id2);
    
    $c->render(json => { 
        success => \1, 
        mensaje => "Colaboración establecida entre $id1 y $id2" 
    });
};

get '/admin/red/grafo' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();
    $c->render(json => $grafo->exportar_grafo());
};

get '/admin/red/aislados' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();
    $c->render(json => { aislados => $grafo->obtener_aislados() });
};

get '/usuario/:id/sugerencias' => sub ($c) {
    my $id = $c->param('id');
    my ($avl, $tabla, $grafo) = $c->init_system();
    
    my $sugerencias = $grafo->obtener_sugerencias($id);
    $c->render(json => { 
        usuario => $id, 
        sugerencias => $sugerencias 
    });
};

# ==================== RUTAS NUEVAS FASE 3 ====================

post '/admin/cargar_relaciones' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();
    my $relaciones = $c->req->json;
    
    if (ref($relaciones) ne 'ARRAY') {
        return $c->render(json => { success => \0, error => "Se esperaba un arreglo JSON" });
    }
    
    my $procesadas = 0;
    foreach my $rel (@$relaciones) {
        my $solicitante = $rel->{solicitante};
        my $receptor = $rel->{receptor};
        my $estado = $rel->{estado};
        
        if ($estado eq 'ACTIVA') {
            $grafo->insertar_arista($solicitante, $receptor);
            $procesadas++;
        } elsif ($estado eq 'PENDIENTE') {
            $grafo->agregar_solicitud($solicitante, $receptor);
            $procesadas++;
        }
        # Si es RECHAZADA, se ignora por requerimiento
    }
    
    $c->render(json => { success => \1, mensaje => "Relaciones procesadas", cantidad => $procesadas });
};

get '/usuario/:id/solicitudes' => sub ($c) {
    my $id = $c->param('id');
    my ($avl, $tabla, $grafo) = $c->init_system();
    $c->render(json => { solicitudes => $grafo->obtener_solicitudes($id) });
};

post '/usuario/responder_solicitud' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();
    my $json = $c->req->json;
    
    my $solicitante = $json->{solicitante};
    my $receptor = $json->{receptor};
    my $respuesta = $json->{respuesta}; # 'ACTIVA' o 'RECHAZADA'
    
    my $creada = $grafo->responder_solicitud($solicitante, $receptor, $respuesta);
    $c->render(json => { success => \1, arista_creada => $creada });
};

get '/admin/red/reporte_adyacencia' => sub ($c) {
    my ($avl, $tabla, $grafo) = $c->init_system();
    $c->render(json => $grafo->reporte_adyacencia());
};

print "Servidor listo. Accede a http://localhost:3000\n";

app->start;