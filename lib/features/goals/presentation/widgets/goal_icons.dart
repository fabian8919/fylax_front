import 'package:fylax_front/core/utils/category_icons.dart';
import 'package:flutter/material.dart';

/// Catálogo de íconos disponibles para los propósitos de ahorro.
/// La clave se persiste en la columna `icon` y el color se elige de la
/// paleta azul/verde de la marca.
const goalIconCatalog = <String, IconData>{
  'car': Icons.directions_car_filled_rounded,
  'moto': Icons.two_wheeler_rounded,
  'travel': Icons.flight_rounded,
  'debt': Icons.credit_card_off_rounded,
  'home': Icons.home_rounded,
  'gadget': Icons.smartphone_rounded,
  'education': Icons.school_rounded,
  'health': Icons.favorite_rounded,
  'emergency': Icons.savings_rounded,
  'gift': Icons.card_giftcard_rounded,
};

IconData goalIcon(String icon) =>
    goalIconCatalog[icon] ?? Icons.flag_rounded;

/// Colores sugeridos para propósitos (paleta de la marca).
const goalColorPalette = <String>[
  '#2E8FFF', // azul
  '#1E5EFF', // azul profundo
  '#00D68F', // verde menta
  '#34E0A1', // verde suave
  '#5EB2FF', // azul claro
  '#3ECF8E', // verde medio
];

Color goalColor(String hex) => categoryColor(hex);
