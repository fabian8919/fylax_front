import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/auth/domain/entities/user.dart';
import 'package:fylax_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:fylax_front/features/categories/domain/entities/category.dart';
import 'package:fylax_front/features/categories/domain/repositories/categories_repository.dart';
import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:fylax_front/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fylax_front/features/sync/domain/entities/sync_status.dart';
import 'package:fylax_front/features/sync/domain/repositories/sync_repository.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/domain/repositories/transactions_repository.dart';

/// Repositorios de demostración: implementan los contratos de dominio con
/// datos realistas en memoria (COP, comercios colombianos) para que la app
/// sea navegable de punta a punta sin backend.
///
/// Se activan cuando no hay API_BASE_URL configurada (ver injection.dart).
/// Cuando el backend FastAPI esté disponible, el mismo contenedor de DI
/// registra las implementaciones reales sin tocar la UI.

// ─────────────────────────── Datos base ───────────────────────────

const _demoUser = User(
  id: 'demo-user-001',
  email: 'camila.restrepo@gmail.com',
  name: 'Camila Restrepo',
  subscriptionTier: 'free',
);

const demoCategories = <Category>[
  Category(
    id: 'cat-domicilios',
    name: 'Domicilios',
    icon: 'delivery',
    color: '#2E8FFF',
    type: CategoryType.expense,
    isSystemDefault: true,
  ),
  Category(
    id: 'cat-restaurantes',
    name: 'Restaurantes',
    icon: 'restaurant',
    color: '#34E0A1',
    type: CategoryType.expense,
    isSystemDefault: true,
  ),
  Category(
    id: 'cat-mercado',
    name: 'Mercado',
    icon: 'groceries',
    color: '#00D68F',
    type: CategoryType.expense,
    isSystemDefault: true,
  ),
  Category(
    id: 'cat-transporte',
    name: 'Transporte',
    icon: 'transport',
    color: '#1E5EFF',
    type: CategoryType.expense,
    isSystemDefault: true,
  ),
  Category(
    id: 'cat-suscripciones',
    name: 'Suscripciones',
    icon: 'subscriptions',
    color: '#5EB2FF',
    type: CategoryType.expense,
    isSystemDefault: true,
  ),
  Category(
    id: 'cat-salud',
    name: 'Salud',
    icon: 'health',
    color: '#7BE8C3',
    type: CategoryType.expense,
    isSystemDefault: true,
  ),
  Category(
    id: 'cat-entretenimiento',
    name: 'Entretenimiento',
    icon: 'entertainment',
    color: '#8FB8DE',
    type: CategoryType.expense,
    isSystemDefault: true,
  ),
  Category(
    id: 'cat-servicios',
    name: 'Servicios',
    icon: 'services',
    color: '#3ECF8E',
    type: CategoryType.expense,
    isSystemDefault: true,
  ),
];

List<Transaction> _buildDemoTransactions() {
  final now = DateTime.now();
  Transaction tx(
    String id,
    String merchant,
    String categoryId,
    double amount,
    int daysAgo, {
    TransactionSource source = TransactionSource.gmailApi,
  }) =>
      Transaction(
        id: id,
        userId: _demoUser.id,
        categoryId: categoryId,
        amount: amount,
        currency: 'COP',
        date: now.subtract(Duration(days: daysAgo)),
        merchantClean: merchant,
        source: source,
        sourceRefId: source == TransactionSource.gmailApi ? 'gmail-$id' : null,
      );

  return [
    tx('t01', 'Rappi', 'cat-domicilios', 42500, 0),
    tx('t02', 'Netflix', 'cat-suscripciones', 29900, 1),
    tx('t03', 'Éxito', 'cat-mercado', 186400, 1),
    tx('t04', 'Uber', 'cat-transporte', 23800, 2),
    tx('t05', 'Crepes & Waffles', 'cat-restaurantes', 89200, 2),
    tx('t06', 'Spotify', 'cat-suscripciones', 14900, 3),
    tx('t07', 'Rappi', 'cat-domicilios', 31200, 4),
    tx('t08', 'Farmatodo', 'cat-salud', 56700, 5),
    tx('t09', 'D1', 'cat-mercado', 94800, 5),
    tx('t10', 'Cine Colombia', 'cat-entretenimiento', 44000, 6),
    tx('t11', 'Enel', 'cat-servicios', 152300, 7),
    tx('t12', 'Uber', 'cat-transporte', 19500, 8),
    tx('t13', 'Juan Valdez', 'cat-restaurantes', 23400, 9),
    tx('t14', 'Rappi', 'cat-domicilios', 38900, 10),
    tx('t15', 'Éxito', 'cat-mercado', 210600, 11),
    tx('t16', 'iCloud+', 'cat-suscripciones', 9900, 12),
    tx(
      't17',
      'Efectivo — cajero',
      'cat-entretenimiento',
      60000,
      13,
      source: TransactionSource.manual,
    ),
    tx('t18', 'Claro', 'cat-servicios', 89900, 14),
    tx('t19', 'Uber', 'cat-transporte', 27100, 15),
    tx('t20', 'Páramo Presenta', 'cat-entretenimiento', 78000, 16),
    tx('t21', 'La 14', 'cat-restaurantes', 64500, 17),
    tx('t22', 'Rappi', 'cat-domicilios', 28700, 18),
    tx('t23', 'Cruz Verde', 'cat-salud', 41300, 19),
    tx('t24', 'D1', 'cat-mercado', 87200, 20),
    tx('t25', 'Movistar Arena', 'cat-entretenimiento', 165000, 21),
    tx('t26', 'Uber', 'cat-transporte', 21400, 22),
    tx('t27', 'Netflix', 'cat-suscripciones', 29900, 23),
    tx('t28', 'Éxito', 'cat-mercado', 143900, 24),
    tx('t29', 'Crepes & Waffles', 'cat-restaurantes', 71800, 25),
    tx('t30', 'Vanti', 'cat-servicios', 96400, 26),
  ];
}

// ─────────────────────────── Auth ───────────────────────────

class DemoAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    return const Right(_demoUser);
  }

  @override
  Future<Either<Failure, User>> syncSessionWithBackend() async =>
      const Right(_demoUser);

  @override
  Future<Either<Failure, Unit>> signOut() async => const Right(unit);

  @override
  Future<Either<Failure, User?>> getCurrentUser() async =>
      const Right(null); // siempre arranca en login (demo)

  @override
  Future<bool> hasGmailReadonlyScope() async => true;
}

// ─────────────────────────── Categorías ───────────────────────────

class DemoCategoriesRepository implements CategoriesRepository {
  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const Right(demoCategories);
  }
}

// ─────────────────────────── Transacciones ───────────────────────────

class DemoTransactionsRepository implements TransactionsRepository {
  DemoTransactionsRepository() : _items = _buildDemoTransactions();

  final List<Transaction> _items;
  int _seq = 100;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? source,
    DateTime? from,
    DateTime? to,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    var filtered = _items.where((t) {
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (source != null && t.source.name != source) return false;
      if (from != null && t.date.isBefore(from)) return false;
      if (to != null && t.date.isAfter(to)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return const Right([]);
    final end =
        (start + pageSize) > filtered.length ? filtered.length : start + pageSize;
    return Right(filtered.sublist(start, end));
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction(
    Transaction tx,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final created = Transaction(
      id: 'demo-${_seq++}',
      userId: _demoUser.id,
      categoryId: tx.categoryId,
      amount: tx.amount,
      currency: tx.currency,
      date: tx.date,
      merchantClean: tx.merchantClean,
      source: tx.source,
    );
    _items.add(created);
    return Right(created);
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    Transaction tx,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _items.indexWhere((t) => t.id == tx.id);
    if (index == -1) return const Left(ServerFailure('No existe'));
    _items[index] = tx;
    return Right(tx);
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((t) => t.id == id);
    return const Right(unit);
  }
}

// ─────────────────────────── Dashboard ───────────────────────────

class DemoDashboardRepository implements DashboardRepository {
  DemoDashboardRepository(this._transactions);

  final DemoTransactionsRepository _transactions;

  @override
  Future<Either<Failure, DashboardSummary>> getSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final result = await _transactions.getTransactions(pageSize: 200);
    final items = result.getOrElse(() => []);

    final now = DateTime.now();
    final thisMonth = items.where(
      (t) => t.date.year == now.year && t.date.month == now.month,
    );

    final spent = thisMonth.fold<double>(0, (s, t) => s + t.amount);
    const income = 3200000.0; // demo: ingreso mensual
    const budget = 2500000.0; // demo: presupuesto de gasto

    final byCategory = <String, double>{};
    for (final t in thisMonth) {
      byCategory.update(
        t.categoryId,
        (v) => v + t.amount,
        ifAbsent: () => t.amount,
      );
    }

    final spending = [
      for (final entry in byCategory.entries)
        CategorySpending(
          categoryId: entry.key,
          categoryName: demoCategories
              .firstWhere(
                (c) => c.id == entry.key,
                orElse: () => demoCategories.first,
              )
              .name,
          amount: entry.value,
          icon: demoCategories
              .firstWhere(
                (c) => c.id == entry.key,
                orElse: () => demoCategories.first,
              )
              .icon,
          color: demoCategories
              .firstWhere(
                (c) => c.id == entry.key,
                orElse: () => demoCategories.first,
              )
              .color,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return Right(
      DashboardSummary(
        monthBalance: income - spent,
        availableBudget: budget - spent,
        spendingByCategory: spending,
      ),
    );
  }
}

// ─────────────────────────── Sincronización ───────────────────────────

class DemoSyncRepository implements SyncRepository {
  @override
  Future<Either<Failure, SyncStatus>> getStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Right(
      SyncStatus(
        status: SyncState.active,
        lastSyncAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> retrySync() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const Right(unit);
  }
}
