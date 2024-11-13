// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/portfolio_provider.dart';
// import '../api/portfolio_service.dart';
// import '../models/portfolio.dart';
// import '../models/stock.dart';

// class MockPortfolioService extends Mock implements PortfolioService {}

// void main() {
//   late MockPortfolioService mockPortfolioService;
//   late ProviderContainer container;

//   setUp(() {
//     mockPortfolioService = MockPortfolioService();
//     container = ProviderContainer(
//       overrides: [
//         portfolioProvider.overrideWithProvider(
//           StateNotifierProvider((ref) => PortfolioNotifier((_) => mockPortfolioService)),
//         ),
//       ],
//     );
//   });

//   tearDown(() {
//     container.dispose();
//   });

//   group('Portfolio Provider Tests', () {
//     test('Buy stock updates portfolio correctly', () async {
//       final portfolioBefore = Portfolio(
//         stocks: [Stock(symbol: 'AAPL', currentPrice: 150, priceHistory: [145, 148, 150])],
//         availableFunds: 1000,
//         totalValue: 150,
//       );
//       final portfolioAfter = Portfolio(
//         stocks: [
//           Stock(symbol: 'AAPL', currentPrice: 150, priceHistory: [145, 148, 150]),
//           Stock(symbol: 'GOOGL', currentPrice: 2000, priceHistory: [1950, 1980, 2000]),
//         ],
//         availableFunds: 500,
//         totalValue: 2150,
//       );

//       when(mockPortfolioService.fetchPortfolio('user123')).thenAnswer((_) async => portfolioBefore);
//       when(mockPortfolioService.buyStock('user123', 'GOOGL', 1)).thenAnswer((_) async {});
//       when(mockPortfolioService.fetchPortfolio('user123')).thenAnswer((_) async => portfolioAfter);

//       await container.read(portfolioProvider.notifier).loadPortfolio('user123');
//       expect(container.read(portfolioProvider).data!.value.stocks.length, 1);

//       await container.read(portfolioProvider.notifier).buyStock('user123', 'GOOGL', 1);
//       expect(container.read(portfolioProvider).data!.value.stocks.length, 2);
//       expect(container.read(portfolioProvider).data!.value.availableFunds, 500);
//     });

//     test('Sell stock updates portfolio correctly', () async {
//       final portfolioBefore = Portfolio(
//         stocks: [Stock(symbol: 'AAPL', currentPrice: 150, priceHistory: [145, 148, 150])],
//         availableFunds: 1000,
//         totalValue: 150,
//       );
//       final portfolioAfter = Portfolio(
//         stocks: [],
//         availableFunds: 1150,
//         totalValue: 0,
//       );

//       when(mockPortfolioService.fetchPortfolio('user123')).thenAnswer((_) async => portfolioBefore);
//       when(mockPortfolioService.sellStock('user123', 'AAPL', 1)).thenAnswer((_) async {});
//       when(mockPortfolioService.fetchPortfolio('user123')).thenAnswer((_) async => portfolioAfter);

//       await container.read(portfolioProvider.notifier).loadPortfolio('user123');
//       expect(container.read(portfolioProvider).data!.value.stocks.length, 1);

//       await container.read(portfolioProvider.notifier).sellStock('user123', 'AAPL', 1);
//       expect(container.read(portfolioProvider).data!.value.stocks.length, 0);
//       expect(container.read(portfolioProvider).data!.value.availableFunds, 1150);
//     });
//   });
// }