#!/usr/bin/perl
use strict;
use warnings;
use lib '.';

use JSON::PP;                  # ← Solo importamos el módulo (sin qw)

use ListaDobleEnlazada;
use ArbolBST;
use ArbolB;
use ArbolAVL;
use ListaCircularDobleProveedores;
use MatrizDispersaProveedorFabricante;
use Medicamento;
use NodoEquipo;
use NodoSuministro;
use NodoPersonal;
use Proveedor;

package CargaJSON;

# =============================================
# CARGA MASIVA INVENTARIO
# =============================================
sub cargar_inventario {
    my ($archivo, $lista_medicamentos, $bst_equipos, $btree_suministros, 
        $lista_proveedores, $matriz) = @_;

    open my $fh, '<', $archivo or die "No se pudo abrir $archivo: $!";
    my $json_text = do { local $/; <$fh> };
    close $fh;

    my $data = JSON::PP::decode_json($json_text);   # ←←← CORRECCIÓN AQUÍ

    my $contador = 0;

    foreach my $prov_hash (@{$data->{proveedor}}) {
        my $nit        = $prov_hash->{nit};
        my $nombre     = $prov_hash->{nombre};
        my $telefono   = $prov_hash->{telefono};
        my $direccion  = $prov_hash->{direccion};

        my $proveedor = $lista_proveedores->buscar_proveedor($nit);
        if (!defined $proveedor) {
            $proveedor = Proveedor->new($nit, $nombre, $telefono, $direccion);
            $lista_proveedores->insertar_proveedor($proveedor);
        }

        foreach my $item (@{$prov_hash->{entrega}}) {
            my $tipo = $item->{tipo};
            $contador++;

            if ($tipo eq "MEDICAMENTO") {
                next if (!defined $item->{fabricante} || $item->{fabricante} eq "" || $item->{cantidad} <= 0);
                my $med = Medicamento->new(
                    $item->{codigo},
                    $item->{nombre},
                    $item->{principio_activo} // "N/A",
                    $item->{fabricante},
                    $item->{precio_unitario},
                    $item->{cantidad},
                    $item->{fecha_vencimiento},
                    $item->{nivel_minimo}
                );
                $lista_medicamentos->insertar_ordenado($med);

            } elsif ($tipo eq "EQUIPO") {
                next if (!defined $item->{fabricante} || $item->{fabricante} eq "" || $item->{cantidad} <= 0);
                my $equipo = NodoEquipo->new(
                    $item->{codigo},
                    $item->{nombre},
                    $item->{fabricante},
                    $item->{precio_unitario},
                    $item->{cantidad},
                    $item->{fecha_ingreso} // "2026-01-01",
                    $item->{nivel_minimo}
                );
                $bst_equipos->insertar($equipo);

            } elsif ($tipo eq "SUMINISTRO") {
                next if (!defined $item->{fabricante} || $item->{fabricante} eq "" || $item->{cantidad} <= 0);
                my $sum = NodoSuministro->new(
                    $item->{codigo},
                    $item->{nombre},
                    $item->{fabricante},
                    $item->{precio_unitario},
                    $item->{cantidad},
                    $item->{fecha_vencimiento} // "2028-12-31",
                    $item->{nivel_minimo}
                );
                $btree_suministros->insertar($sum);
            }

            # VALIDACIÓN ANTES DE INSERTAR EN MATRIZ
if (defined $item->{fabricante} && $item->{fabricante} ne "" && $item->{cantidad} > 0) {
    $matriz->insertar($nit, $item->{fabricante}, $item->{cantidad});
} else {
    print "Dato inválido ignorado en matriz (Proveedor: $nit)\n";
}
            if (defined $item->{fabricante} && $item->{fabricante} ne "" && $item->{cantidad} > 0) {
                $proveedor->agregar_entrega(
                    $prov_hash->{fecha_entrega},
                    $prov_hash->{numero_factura},
                    $tipo,
                    $item->{codigo},
                    $item->{nombre},
                    $item->{fabricante},
                    $item->{precio_unitario},
                    $item->{cantidad}
                );
            }
        }
    }

    print "✅ Carga masiva de inventario completada: $contador productos procesados.\n";
}

# =============================================
# CARGA MASIVA USUARIOS
# =============================================
sub cargar_usuarios {
    my ($archivo, $avl_personal) = @_;

    open my $fh, '<', $archivo or die "No se pudo abrir $archivo: $!";
    my $json_text = do { local $/; <$fh> };
    close $fh;

    my $data = JSON::PP::decode_json($json_text);

    my $cont = 0;
    foreach my $u (@{$data->{usuarios}}) {
        my $usuario = NodoPersonal->new(
            $u->{numero_colegio},
            $u->{nombre_completo},
            $u->{tipo_usuario},
            $u->{departamento},
            $u->{especialidad} // "N/A",
            $u->{contrasena}
        );
        $avl_personal->insertar($usuario);
        $cont++;
    }

    print "✅ Carga masiva de usuarios completada: $cont usuarios insertados en AVL.\n";
}

1;