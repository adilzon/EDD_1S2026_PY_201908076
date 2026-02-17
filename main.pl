use strict;
use warnings;

use lib 'estructuras';
use Medicamento;
use ListaInventario;

my $m1 = Medicamento::crear("MED002", "Ibuprofeno", "Ibuprofeno", "LabA", 20, "2026-05-01", 5.50, 10);
my $m2 = Medicamento::crear("MED001", "Paracetamol", "Acetaminofen", "LabB", 50, "2026-01-01", 3.00, 15);
my $m3 = Medicamento::crear("MED003", "Amoxicilina", "Amoxicilina", "LabC", 10, "2025-12-01", 8.75, 5);

ListaInventario::insertar($m1);
ListaInventario::insertar($m2);
ListaInventario::insertar($m3);

ListaInventario::mostrar();
