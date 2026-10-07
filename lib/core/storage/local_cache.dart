/// Caché local (Isar) que habilita el modo offline del patrón Repository
/// (PRD §5.1): los repositorios deciden entre fuente remota (REST) y caché
/// local según conectividad y frescura del dato.
///
/// TODO(Fase 5): generar colecciones Isar para Transaction y Category
/// con build_runner; aquí vive la apertura/cierre de la instancia.
class LocalCache {
  LocalCache._();

  // static late final Isar _isar;
  // static Future<void> init() async { ... }

  // Future<void> cacheTransactions(List<TransactionDto> items) { ... }
  // Future<List<TransactionDto>> getCachedTransactions() { ... }
}
