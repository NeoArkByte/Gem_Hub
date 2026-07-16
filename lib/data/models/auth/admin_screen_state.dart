import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';

class AdminScreenState {
  final List<Job> jobs;
  final List<Gem> gems;

  AdminScreenState({required this.jobs, required this.gems});
}
