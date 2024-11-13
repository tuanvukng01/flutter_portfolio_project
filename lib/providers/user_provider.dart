// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../models/user.dart';
// // import '../api/portfolio_service.dart';
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import '../utils/api_constants.dart';

// // final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
// //   return UserNotifier(ref.read);
// // });

// // class UserNotifier extends StateNotifier<AsyncValue<User?>> {
// //   final PortfolioService _portfolioService;
// //   final Reader _read;
// //   String? _token;

// //   UserNotifier(this._read)
// //       : _portfolioService = PortfolioService(),
// //         super(AsyncValue.data(null)); // Start with no authenticated user

// //   // Check if user is authenticated
// //   bool get isAuthenticated => state.value != null;

// //   // Sign out method to clear user data
// //   Future<void> signOut() async {
// //     state = AsyncValue.data(null); // Clear user data
// //     _token = null; // Clear token
// //   }

// //   // Register a new user
// //   Future<void> register(String email, String password, String name) async {
// //   final url = Uri.parse('$apiBaseUrl/api/register');
// //   try {
// //     final response = await http.post(
// //       url,
// //       headers: {
// //         "Content-Type": "application/json",
// //       },
// //       body: json.encode({
// //         "email": email,
// //         "password": password,
// //         "name": name,
// //       }),
// //     );

// //     if (response.statusCode == 201) {
// //       final data = json.decode(response.body);
// //       await loadUser(data['userId']); // Load user data after successful registration
// //     } else if (response.statusCode == 409) {
// //       throw Exception('User already exists');
// //     } else {
// //       throw Exception('Registration failed with status: ${response.statusCode}');
// //     }
// //   } catch (e) {
// //     print("Error in register: $e");
// //     state = AsyncValue.error(e);
// //   }
// // }

// //   // Log in an existing user
// //   Future<void> login(String email, String password) async {
// //   final url = Uri.parse('$apiBaseUrl/api/login');
// //   try {
// //     final response = await http.post(
// //       url,
// //       headers: {
// //         "Content-Type": "application/json",
// //       },
// //       body: json.encode({
// //         "email": email,
// //         "password": password,
// //       }),
// //     );

// //     if (response.statusCode == 200) {
// //       final data = json.decode(response.body);
// //       _token = data['token']; // Store the token
// //       await loadUser(data['userId']); // Load user data after login
// //     } else if (response.statusCode == 404) {
// //       throw Exception('User not found');
// //     } else if (response.statusCode == 401) {
// //       throw Exception('Invalid password');
// //     } else {
// //       throw Exception('Login failed with status: ${response.statusCode}');
// //     }
// //   } catch (e) {
// //     print("Login error: $e");
// //     state = AsyncValue.error(e);
// //   }
// // }


// //   Future<void> loadUser(String userId, {double? updatedFunds}) async {
// //     try {
// //         state = const AsyncValue.loading();
// //         final portfolio = await _portfolioService.fetchPortfolio(userId);

// //         // Recalculate total value directly
// //         final recalculatedTotalValue = portfolio.calculateTotalValue();

// //         final user = User(
// //             id: userId,
// //             availableFunds: updatedFunds ?? portfolio.availableFunds,
// //             totalValue: recalculatedTotalValue,  // Use recalculated value here
// //         );

// //         print("User data loaded: Available Funds: ${user.availableFunds}, Total Portfolio Value: ${user.totalValue}");
// //         state = AsyncValue.data(user);
// //     } catch (e) {
// //         state = AsyncValue.error(e);
// //     }
// // }

// //   Future<void> updateFunds(double newFunds) async {
// //     print("Updating user funds to $newFunds");
// //     try {
// //       state = state.whenData((user) {
// //         if (user == null) {
// //           throw Exception('User not loaded');
// //         }
// //         final updatedUser = user.copyWith(availableFunds: newFunds);
// //         print("User funds updated to: ${updatedUser.availableFunds}");
// //         return updatedUser;
// //       });
// //     } catch (e) {
// //       print("Error updating funds: $e");
// //       state = AsyncValue.error(e);
// //     }
// //   }

// //   Future<void> updateTotalValue(double newTotalValue) async {
// //     state = state.whenData((user) {
// //       if (user == null) {
// //         throw Exception('User not loaded');
// //       }
// //       final updatedUser = user.copyWith(totalValue: newTotalValue);
// //       print("User total value updated to: ${updatedUser.totalValue}");  // Log the new total value
// //       return updatedUser;
// //     });
// // }
// // }

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/user.dart';
// import '../api/portfolio_service.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../utils/api_constants.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
//   return UserNotifier(ref.read);
// });

// class UserNotifier extends StateNotifier<AsyncValue<User?>> {
//   final PortfolioService _portfolioService;
//   final Reader _read;
//   final _storage = FlutterSecureStorage(); // Secure storage instance
//   String? _token;

//   UserNotifier(this._read)
//       : _portfolioService = PortfolioService(),
//         super(AsyncValue.data(null));

//   bool get isAuthenticated => state.value != null;

//   Future<void> signOut() async {
//     state = AsyncValue.data(null);
//     _token = null;
//     await _storage.delete(key: 'authToken'); // Clear token from secure storage
//   }

//   Future<void> register(String email, String password, String name) async {
//     final url = Uri.parse('$apiBaseUrl/api/register');
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({
//           "email": email,
//           "password": password,
//           "name": name,
//         }),
//       );

//       if (response.statusCode == 201) {
//         final data = json.decode(response.body);
//         await loadUser(data['userId']);
//       } else {
//         throw Exception('Registration failed with status: ${response.statusCode}, body: ${response.body}');
//       }
//     } catch (e) {
//       print("Error in register: $e");
//       state = AsyncValue.error(e);
//     }
//   }

//   Future<void> login(String email, String password) async {
//     final url = Uri.parse('$apiBaseUrl/api/login');
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({
//           "email": email,
//           "password": password,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _token = data['token'];
//         await _storage.write(key: 'authToken', value: _token); // Store token securely
//         await loadUser(data['userId']);
//       } else {
//         throw Exception('Login failed');
//       }
//     } catch (e) {
//       state = AsyncValue.error(e);
//     }
//   }

//   Future<void> loadUser(String userId, {double? updatedFunds}) async {
//     try {
//         state = const AsyncValue.loading();
//         final portfolio = await _portfolioService.fetchPortfolio(userId);

//         final recalculatedTotalValue = portfolio.calculateTotalValue();

//         final user = User(
//             id: userId,
//             availableFunds: updatedFunds ?? portfolio.availableFunds,
//             totalValue: recalculatedTotalValue,
//         );

//         print("User data loaded: Available Funds: ${user.availableFunds}, Total Portfolio Value: ${user.totalValue}");
//         state = AsyncValue.data(user);
//     } catch (e) {
//         state = AsyncValue.error(e);
//     }
//   }

//   Future<void> updateFunds(double newFunds) async {
//     print("Updating user funds to $newFunds");
//     try {
//       state = state.whenData((user) {
//         if (user == null) {
//           throw Exception('User not loaded');
//         }
//         final updatedUser = user.copyWith(availableFunds: newFunds);
//         print("User funds updated to: ${updatedUser.availableFunds}");
//         return updatedUser;
//       });
//     } catch (e) {
//       print("Error updating funds: $e");
//       state = AsyncValue.error(e);
//     }
//   }

//   Future<void> updateTotalValue(double newTotalValue) async {
//     state = state.whenData((user) {
//       if (user == null) {
//         throw Exception('User not loaded');
//       }
//       final updatedUser = user.copyWith(totalValue: newTotalValue);
//       print("User total value updated to: ${updatedUser.totalValue}");
//       return updatedUser;
//     });
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../api/portfolio_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User>>((ref) {
  return UserNotifier(ref.read);
});

class UserNotifier extends StateNotifier<AsyncValue<User>> {
  final PortfolioService _portfolioService = PortfolioService();
  final Reader _read;
  String? _token;

  UserNotifier(this._read) : super(const AsyncValue.loading()) {
    loadUser('user123');  // Load the mock user on init for testing
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/api/login'); // Login endpoint URL
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        loadUser(data['userId']); // Load user data after login
      } else {
        print("Login failed: ${response.body}");
        throw Exception('Failed to log in');
      }
    } catch (e) {
      state = AsyncValue.error(e);
    }
  }


  Future<void> loadUser(String userId, {double? updatedFunds}) async {
    try {
        state = const AsyncValue.loading();
        final portfolio = await _portfolioService.fetchPortfolio(userId);

        // Recalculate total value directly
        final recalculatedTotalValue = portfolio.calculateTotalValue();

        final user = User(
            id: userId,
            availableFunds: updatedFunds ?? portfolio.availableFunds,
            totalValue: recalculatedTotalValue,  // Use recalculated value here
        );

        print("User data loaded: Available Funds: ${user.availableFunds}, Total Portfolio Value: ${user.totalValue}");
        state = AsyncValue.data(user);
    } catch (e) {
        state = AsyncValue.error(e);
    }
}

  Future<void> updateFunds(double newFunds) async {
    print("Updating user funds to $newFunds");
    try {
      state = state.whenData((user) {
        final updatedUser = user.copyWith(availableFunds: newFunds);
        print("User funds updated to: ${updatedUser.availableFunds}");
        return updatedUser;
      });
    } catch (e) {
      print("Error updating funds: $e");
      state = AsyncValue.error(e);
    }
  }

  Future<void> updateTotalValue(double newTotalValue) async {
    state = state.whenData((user) {
      final updatedUser = user.copyWith(totalValue: newTotalValue);
      print("User total value updated to: ${updatedUser.totalValue}");  // Log the new total value
      return updatedUser;
    });
}
}