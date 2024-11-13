// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/user_provider.dart';

// class RegisterPage extends ConsumerWidget {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userNotifier = ref.read(userProvider.notifier); // Renamed to userNotifier

//     Future<void> _register() async {
//       final email = _emailController.text.trim();
//       final password = _passwordController.text.trim();
//       final name = _nameController.text.trim();

//       try {
//         await userNotifier.register(email, password, name); // Use the renamed variable
//         Navigator.pushReplacementNamed(context, '/home'); // Navigate to home if registration is successful
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Registration failed: $e')),
//         );
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text('Create Account')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _register,
//               child: Text('Create Account'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }