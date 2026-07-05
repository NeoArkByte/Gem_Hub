import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/data/repositories/job_market/job_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'marketplace_viewmodel.g.dart';

@riverpod
class MarketplaceViewModel extends _$MarketplaceViewModel {
  List<Job> _allJobs = [];

  String _query = '';
  String _category = 'All Jobs';
  String _location = 'All Locations';
  double _minSalary = 0;
  double _maxSalary = 300000;

  String get currentCategory => _category;
  String get currentLocation => _location;
  double get currentMinSalary => _minSalary;
  double get currentMaxSalary => _maxSalary;

  @override
  Future<List<Job>> build() async {
    final repository = ref.read(jobRepositoryProvider);
    _allJobs = await repository.getApprovedJobs();
    return _allJobs;
  }

  void _applyFilters() {
    print("🔎 [FILTER START]");
    print(
        "Filters → Category: '$_category', Location: '$_location', Salary Range: $_minSalary - $_maxSalary");
    print("Total jobs before filtering: ${_allJobs.length}");

    final filteredList = _allJobs.where((job) {
    
      bool matchesQuery = true;
      if (_query.isNotEmpty) {
        matchesQuery =
            job.title.toLowerCase().contains(_query.toLowerCase());
      }

    
      bool matchesCategory = true;
      if (_category.isNotEmpty && _category != 'All Jobs') {
        matchesCategory =
            job.tags.toLowerCase().contains(_category.toLowerCase());

        print(
            "Category Check → Job: '${job.title}', Tags: '${job.tags}', Match: $matchesCategory");
      }

      bool matchesLocation = true;
      if (_location.isNotEmpty &&
          _location != 'All Locations') {
        final jobLocation =
            job.companyInfo?.toLowerCase() ?? '';

        matchesLocation =
            jobLocation.contains(_location.toLowerCase());

        print(
            "Location Check → Job: '${job.title}', Location: '$jobLocation', Match: $matchesLocation");
      }

      bool matchesSalary = true;
      if (job.minSalary != null ||
          job.maxSalary != null) {
        double jobMin = job.minSalary ?? 0;
        double jobMax = job.maxSalary ?? double.infinity;

        matchesSalary =
            (jobMin <= _maxSalary) &&
                (jobMax >= _minSalary);
      }

      bool passes =
          matchesQuery &&
              matchesCategory &&
              matchesLocation &&
              matchesSalary;

      if (!passes) {
        print(
            " Excluded → '${job.title}' (Query:$matchesQuery, Category:$matchesCategory, Location:$matchesLocation, Salary:$matchesSalary)");
      } else {
        print(" Included → '${job.title}'");
      }

      return passes;
    }).toList();

    print(
        " Jobs after filtering: ${filteredList.length}");
    print(" [FILTER END]\n");

    state = AsyncValue.data(filteredList);
  }

  void updateSearchQuery(String query) {
    _query = query;
    _applyFilters();
  }

  void clearFilters() {
    _category = 'All Jobs';
    _location = 'All Locations';
    _minSalary = 0;
    _maxSalary = 300000;

    _applyFilters();
  }

  void updateCategory(String category) {
    _category = category;
    _applyFilters();
  }

  void updateFilters({
    required String category,
    required String location,
    required double minSalary,
    required double maxSalary,
  }) {
    _category = category;
    _location = location;
    _minSalary = minSalary;
    _maxSalary = maxSalary;

    _applyFilters();
  }
}