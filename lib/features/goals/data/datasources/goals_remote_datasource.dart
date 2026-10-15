import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/goals/data/models/goal_model.dart';

abstract class GoalsRemoteDataSource {
  Future<List<GoalModel>> getGoals();
  Future<GoalModel> createGoal(GoalModel goal);
  Future<GoalModel> updateGoal(GoalModel goal);
  Future<GoalModel> addContribution(String id, double amount);
  Future<void> deleteGoal(String id);
}

class GoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  GoalsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<GoalModel>> getGoals() async {
    final response = await _client.get<List<dynamic>>('/goals');
    return (response.data ?? const [])
        .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<GoalModel> createGoal(GoalModel goal) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/goals',
      data: goal.toCreateJson(),
    );
    return GoalModel.fromJson(response.data!);
  }

  @override
  Future<GoalModel> updateGoal(GoalModel goal) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/goals/${goal.id}',
      data: goal.toUpdateJson(),
    );
    return GoalModel.fromJson(response.data!);
  }

  @override
  Future<GoalModel> addContribution(String id, double amount) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/goals/$id/contributions',
      data: {'amount': amount},
    );
    return GoalModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _client.delete<void>('/goals/$id');
  }
}
