import 'dart:math' as math;

class AuctionUtils {
  static double calculateAuctionPrice({
    required DateTime addedDate,
    required double basePrice,
    required DateTime currentDate,
  }) {
    if (basePrice <= 0) return 0.0;

    // Calculate the number of full weeks (7-day intervals) elapsed
    final difference = currentDate.difference(addedDate);
    final weeks = difference.inDays ~/ 7;

    if (weeks <= 1) {
      return basePrice * 1.50;
    }

    final price = basePrice * (1.50 - ((weeks - 1) * 0.05));
    final floorPrice = basePrice * 0.10;

    return math.max(floorPrice, price);
  }
}
