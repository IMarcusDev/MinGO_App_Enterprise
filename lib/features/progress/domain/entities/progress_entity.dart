import "package:equatable/equatable.dart";
class UserProgress extends Equatable {
  final String userId;
  final int totalPoints;
  final int signedLearned;
  const UserProgress({required this.userId, required this.totalPoints, required this.signedLearned});
  @override List<Object?> get props => [userId, totalPoints];
}
