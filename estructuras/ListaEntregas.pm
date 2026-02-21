package ListaEntregas;

use strict;
use warnings;

use matriz_dispersa::MatrizDispersa;

# =========================================
# MATRIZ GLOBAL DE COMPARACION DE PRECIOS
# Filas    -> Proveedores (indice)
# Columnas -> Medicamentos (indice)
# Valor    -> Precio
# =========================================

# =========================================
# Insertar entrega a un proveedor
# =========================================
sub insertar {
    my ($proveedor, $entrega) = @_;

    # 1. Insertar entrega en la lista simple del proveedor
    if (!defined $proveedor->{entregas}) {
        $proveedor->{entregas} = $entrega;
    } else {
        my $actual = $proveedor->{entregas};
        while ($actual->{siguiente}) {
            $actual = $actual->{siguiente};
        }
        $actual->{siguiente} = $entrega;
    }

    # 2. Insertar precio en la matriz dispersa
    my $fila  = $proveedor->{indice};
    my $col   = $entrega->{medicamento_idx};
    my $valor = $entrega->{precio};

    MatrizDispersa::insertar($fila, $col, $valor);
}

# =========================================
# Mostrar entregas de un proveedor
# =========================================
sub mostrar {
    my ($proveedor) = @_;

    print "  Entregas:\n";

    my $actual = $proveedor->{entregas};

    if (!defined $actual) {
        print "   - No hay entregas registradas\n";
        return;
    }

    while ($actual) {
        print "   Fecha: $actual->{fecha} | ";
        print "Factura: $actual->{factura} | ";
        print "Medicamento: $actual->{medicamento} | ";
        print "Cantidad: $actual->{cantidad} | ";
        print "Precio: Q$actual->{precio}\n";

        $actual = $actual->{siguiente};
    }
}

# =========================================
# Mostrar matriz de comparacion de precios
# =========================================
sub mostrar_matriz_precios {
    MatrizDispersa::imprimir_matriz();
}

1;