// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'pages/portfolio_page.dart';
// import 'pages/stock_search_page.dart';
// import 'pages/transaction_history_page.dart';
// import 'pages/login_page.dart';
// import 'pages/register_page.dart';
// import 'providers/user_provider.dart';

// void main() {
//   runApp(
//     ProviderScope(
//       child: StockTradingApp(),
//     ),
//   );
// }

// class StockTradingApp extends ConsumerStatefulWidget {
//   @override
//   _StockTradingAppState createState() => _StockTradingAppState();
// }

// class _StockTradingAppState extends ConsumerState<StockTradingApp> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     PortfolioPage(),
//     StockSearchPage(),
//     TransactionHistoryPage(),
//   ];

//   // void _onItemTapped(int index) {
//   //   if (index == 3) {
//   //     _signOut();
//   //   } else {
//   //     setState(() {
//   //       _selectedIndex = index;
//   //     });
//   //   }
//   // }

//   // void _signOut() {
//   //   ref.read(userProvider.notifier).signOut(); // Sign out via provider
//   //   setState(() {
//   //     _selectedIndex = 0; // Reset selected index
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final isAuthenticated = ref.watch(userProvider).value != null; // Check if a user is loaded

//     return MaterialApp(
//       title: 'Personal Stock Trading',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: isAuthenticated
//           ? Scaffold(
//               body: _pages[_selectedIndex],
//               bottomNavigationBar: BottomNavigationBar(
//                 type: BottomNavigationBarType.fixed,
//                 selectedFontSize: 14,
//                 unselectedFontSize: 12,
//                 selectedItemColor: Colors.blueAccent,
//                 unselectedItemColor: Colors.grey,
//                 items: [
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.home, size: 30),
//                     label: 'Portfolio',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.search, size: 30),
//                     label: 'Search',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.history, size: 30),
//                     label: 'Transactions',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.logout, size: 30, color: Colors.red),
//                     label: 'Sign Out',
//                   ),
//                 ],
//                 currentIndex: _selectedIndex,
//                 // onTap: _onItemTapped,
//               ),
//             )
//           : LoginPage(), // Directly show login page when not authenticated
//       // routes: {
//       //   '/register': (context) => RegisterPage(),
//       // },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/portfolio_page.dart';
import 'pages/stock_search_page.dart';
import 'pages/transaction_history_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(
    ProviderScope(
      child: StockTradingApp(),
    ),
  );
}

class StockTradingApp extends StatefulWidget {
  @override
  _StockTradingAppState createState() => _StockTradingAppState();
}

class _StockTradingAppState extends State<StockTradingApp> {
  int _selectedIndex = 0;
  bool _isAuthenticated = false; // Add this to control login status

  // List of pages to navigate to
  final List<Widget> _pages = [
    PortfolioPage(),
    StockSearchPage(),
    TransactionHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Stock Trading',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: _isAuthenticated ? '/home' : '/login', // Show login if not authenticated
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Portfolio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Transactions',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      },
    );
  }
}