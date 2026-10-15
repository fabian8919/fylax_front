/// Parseo tolerante de montos de la API.
///
/// FastAPI serializa los campos `Decimal` de Python como *strings* JSON
/// ("123.45") para no perder precisión; un `as num` directo revienta con
/// `type 'String' is not a subtype of type 'num'`. Este helper acepta
/// `num` o `String` y devuelve `double`.
double parseApiAmount(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
