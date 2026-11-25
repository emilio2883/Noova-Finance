import '../models/transaction.dart';

/// One category definition for seeding (parent or leaf).
typedef CategoryDef = ({
  String name,
  TransactionType type,
  bool isGroup,
  bool isVariable,
  bool isRecurring,
  int order,
  String? importKey,
  String? parent,
});

/// Default category tree per the "Categorias" tab of NOOVA Estado Financiero.
/// 8 principals (Ingresos + 7 expense groups) and their leaves.
/// importKey = the row label used in the Y26 data sheet, so the importer maps
/// data rows to the right (possibly renamed) category.
class DefaultCategories {
  static const List<CategoryDef> defs = [
    // ── Principals ──
    (name: 'Ingresos', type: TransactionType.income, isGroup: true,
        isVariable: false, isRecurring: false, order: 1, importKey: null, parent: null),
    (name: 'Impuestos', type: TransactionType.expense, isGroup: true,
        isVariable: false, isRecurring: false, order: 10, importKey: null, parent: null),
    (name: 'Casa', type: TransactionType.expense, isGroup: true,
        isVariable: false, isRecurring: false, order: 11, importKey: null, parent: null),
    (name: 'Seguro', type: TransactionType.expense, isGroup: true,
        isVariable: false, isRecurring: false, order: 12, importKey: null, parent: null),
    (name: 'Alimentos', type: TransactionType.expense, isGroup: true,
        isVariable: false, isRecurring: false, order: 13, importKey: null, parent: null),
    (name: 'Carro', type: TransactionType.expense, isGroup: true,
        isVariable: false, isRecurring: false, order: 14, importKey: null, parent: null),
    (name: 'Otros', type: TransactionType.expense, isGroup: true,
        isVariable: false, isRecurring: false, order: 15, importKey: null, parent: null),
    (name: 'Prestamos', type: TransactionType.expense, isGroup: true,
        isVariable: false, isRecurring: false, order: 16, importKey: null, parent: null),

    // ── Ingresos children ──
    (name: 'Salario', type: TransactionType.income, isGroup: false,
        isVariable: false, isRecurring: true, order: 101, importKey: 'Salario', parent: 'Ingresos'),
    (name: 'Otros Ingresos', type: TransactionType.income, isGroup: false,
        isVariable: true, isRecurring: false, order: 102, importKey: 'Otros Ingresos', parent: 'Ingresos'),

    // ── Impuestos children ──
    (name: 'Impuesto Sobre la Renta', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 110, importKey: 'Impuesto Sobre la Renta', parent: 'Impuestos'),
    (name: 'Seguro Social', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 111, importKey: 'Seguro Social', parent: 'Impuestos'),
    (name: 'Seguro Educativo', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 112, importKey: 'Seguro Educativo', parent: 'Impuestos'),

    // ── Casa children ──
    (name: 'Gas', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 120, importKey: 'Gas', parent: 'Casa'),
    (name: 'Agua IDAAN', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 121, importKey: 'IDAAN', parent: 'Casa'),
    (name: 'Mantenimiento Augusta', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 122, importKey: 'Mantenimiento de Casa', parent: 'Casa'),
    (name: 'Mantenimiento Lajas', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 123, importKey: 'Mantenimiento casa de playa', parent: 'Casa'),

    // ── Seguro children ──
    (name: 'Progreso', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 130, importKey: 'Progreso', parent: 'Seguro'),
    (name: 'MAFRE - CASA', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 131, importKey: 'MAFRE - CASA', parent: 'Seguro'),
    (name: 'PALIG - Salud', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 132, importKey: 'PALIG - Salud', parent: 'Seguro'),
    (name: 'MAFRE - CARRO', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 133, importKey: 'MAFRE - CARRO', parent: 'Seguro'),
    (name: 'Seguro médico padres', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 134, importKey: 'Seguro médico padres', parent: 'Seguro'),

    // ── Alimentos children ──
    (name: 'Restaurante', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 140, importKey: 'Restaurante', parent: 'Alimentos'),
    (name: 'Supermercado', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 141, importKey: 'Supermercado', parent: 'Alimentos'),

    // ── Carro children ──
    (name: 'Gasolina', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 150, importKey: 'Gasolina', parent: 'Carro'),
    (name: 'PANAPASS', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 151, importKey: 'PANAPASS', parent: 'Carro'),

    // ── Otros children ──
    (name: 'Valeria', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 160, importKey: 'Valeria', parent: 'Otros'),
    (name: 'Lala', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 161, importKey: 'Lala', parent: 'Otros'),
    (name: 'Viaje (All in one)', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 162, importKey: 'Viaje (All in one)', parent: 'Otros'),
    (name: 'Gastos Medicos', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 163, importKey: 'Gastos Medicos', parent: 'Otros'),
    (name: 'Gastos generales', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 164, importKey: 'Gastos generales', parent: 'Otros'),

    // ── Prestamos children ──
    (name: 'Hipoteca Augusta', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 170, importKey: 'Casa - Augusta/GG', parent: 'Prestamos'),
    (name: 'Hipoteca Golf Garden', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 171, importKey: null, parent: 'Prestamos'),
    (name: 'QLU MBA - IFARHU', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 172, importKey: 'QLU MBA - IFARHU', parent: 'Prestamos'),
  ];
}
