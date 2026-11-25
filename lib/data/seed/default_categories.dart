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

/// Default category tree based on the Y26 sheet of Estado Financiero-2.xlsx.
/// 2-level hierarchy: 6 expense principals + income/expense leaves.
class DefaultCategories {
  static const List<CategoryDef> defs = [
    // ── Income leaves (top-level) ──
    (name: 'Salario', type: TransactionType.income, isGroup: false,
        isVariable: false, isRecurring: true, order: 1, importKey: 'Salario', parent: null),
    (name: 'Otros Ingresos', type: TransactionType.income, isGroup: false,
        isVariable: true, isRecurring: false, order: 2, importKey: 'Otros Ingresos', parent: null),

    // ── Expense principals (groups) ──
    (name: 'Impuestos y Prestamos', type: TransactionType.expense, isGroup: true,
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

    // ── Impuestos y Prestamos children (fixed) ──
    (name: 'Impuesto Sobre la Renta', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 101, importKey: 'Impuesto Sobre la Renta', parent: 'Impuestos y Prestamos'),
    (name: 'Seguro Social', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 102, importKey: 'Seguro Social', parent: 'Impuestos y Prestamos'),
    (name: 'Seguro Educativo', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 103, importKey: 'Seguro Educativo', parent: 'Impuestos y Prestamos'),

    // ── Casa children (fixed) ──
    (name: 'Gas', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 111, importKey: 'Gas', parent: 'Casa'),
    (name: 'IDAAN', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 112, importKey: 'IDAAN', parent: 'Casa'),
    (name: 'Mantenimiento de Casa', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 113, importKey: 'Mantenimiento de Casa', parent: 'Casa'),
    (name: 'Casa - Augusta/GG', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 114, importKey: 'Casa - Augusta/GG', parent: 'Casa'),
    (name: 'QLU MBA - IFARHU', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 115, importKey: 'QLU MBA - IFARHU', parent: 'Casa'),
    (name: 'Mantenimiento casa de playa', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 116, importKey: 'Mantenimiento casa de playa', parent: 'Casa'),

    // ── Seguro children (fixed) ──
    (name: 'Progreso', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 121, importKey: 'Progreso', parent: 'Seguro'),
    (name: 'MAFRE - CASA', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 122, importKey: 'MAFRE - CASA', parent: 'Seguro'),
    (name: 'PALIG - Salud', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 123, importKey: 'PALIG - Salud', parent: 'Seguro'),
    (name: 'MAFRE - CARRO', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 124, importKey: 'MAFRE - CARRO', parent: 'Seguro'),
    (name: 'Seguro médico padres', type: TransactionType.expense, isGroup: false,
        isVariable: false, isRecurring: true, order: 125, importKey: 'Seguro médico padres', parent: 'Seguro'),

    // ── Alimentos children (variable) ──
    (name: 'Restaurante', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 131, importKey: 'Restaurante', parent: 'Alimentos'),
    (name: 'Supermercado', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 132, importKey: 'Supermercado', parent: 'Alimentos'),

    // ── Carro children (variable) ──
    (name: 'Gasolina', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 141, importKey: 'Gasolina', parent: 'Carro'),
    (name: 'PANAPASS', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 142, importKey: 'PANAPASS', parent: 'Carro'),

    // ── Otros children (variable) ──
    (name: 'Valeria', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 151, importKey: 'Valeria', parent: 'Otros'),
    (name: 'Lala', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 152, importKey: 'Lala', parent: 'Otros'),
    (name: 'Viaje (All in one)', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 153, importKey: 'Viaje (All in one)', parent: 'Otros'),
    (name: 'Gastos Medicos', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 154, importKey: 'Gastos Medicos', parent: 'Otros'),
    (name: 'Gastos generales', type: TransactionType.expense, isGroup: false,
        isVariable: true, isRecurring: false, order: 155, importKey: 'Gastos generales', parent: 'Otros'),
  ];
}
