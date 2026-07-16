import 'package:flutter_test/flutter_test.dart';
import 'package:gemhub/features/inventory/view/auction_utils.dart';

void main() {
  group('AuctionUtils.calculateAuctionPrice Tests', () {
    final basePrice = 1000.0;
    final baseDate = DateTime(2026, 7, 7);

    test('Week 0 - same day returns basePrice + 50%', () {
      final current = DateTime(2026, 7, 7);
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: basePrice,
        currentDate: current,
      );
      expect(price, equals(1500.0));
    });

    test('Week 0 - 6 days later returns basePrice + 50%', () {
      final current = DateTime(2026, 7, 13);
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: basePrice,
        currentDate: current,
      );
      expect(price, equals(1500.0));
    });

    test('Week 1 - 13 days later returns basePrice + 50%', () {
      final current = DateTime(2026, 7, 20); // 13 days is Week 1
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: basePrice,
        currentDate: current,
      );
      expect(price, equals(1500.0));
    });

    test('Week 2 - 14 days later reduces price by 5% of basePrice (1.45x)', () {
      final current = DateTime(2026, 7, 21); // exactly 14 days is Week 2
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: basePrice,
        currentDate: current,
      );
      expect(price, equals(1450.0));
    });

    test('Week 3 - 21 days later reduces price by 10% of basePrice (1.40x)',
        () {
      final current = DateTime(2026, 7, 28);
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: basePrice,
        currentDate: current,
      );
      expect(price, equals(1400.0));
    });

    test('Week 11 - 77 days later is exactly basePrice (1.00x)', () {
      final current = DateTime(2026, 9, 22); // 77 days (11 weeks)
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: basePrice,
        currentDate: current,
      );
      expect(price, equals(1000.0));
    });

    test('Week 30 - 210 days later is floored at 10%', () {
      final current = DateTime(2027, 2,
          2); // 210 days (30 weeks) (1.5 - 29*0.05 = 0.05, floored at 0.10)
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: basePrice,
        currentDate: current,
      );
      expect(price, equals(100.0));
    });

    test('Negative base price returns 0.0', () {
      final current = DateTime(2026, 7, 7);
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: -500.0,
        currentDate: current,
      );
      expect(price, equals(0.0));
    });

    test('Zero base price returns 0.0', () {
      final current = DateTime(2026, 7, 7);
      final price = AuctionUtils.calculateAuctionPrice(
        addedDate: baseDate,
        basePrice: 0.0,
        currentDate: current,
      );
      expect(price, equals(0.0));
    });
  });
}
