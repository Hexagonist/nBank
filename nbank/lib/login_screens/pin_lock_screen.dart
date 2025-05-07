// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import '../navigation/app_routes.dart';
// import 'login_screen.dart';


// class PinCodeWidget extends StatefulWidget {
//   const PinCodeWidget({super.key});

//   @override
//   // _PinLockScreenState createState() => _PinLockScreenState();
//   State<PinCodeWidget> createState() => _PinCodeWidgetState();
// }

// // class _PinLockScreenState extends State<PinLockScreen> {
// //   final TextEditingController _pinController = TextEditingController();

// //   void _checkPin() {
// //     if (loggedInUser == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Brak zalogowanego użytkownika")),
// //       );
// //       Navigator.pushReplacementNamed(context, AppRoutes.login);
// //       return;
// //     }

// //     if (_pinController.text == loggedInUser!.pin) {
// //       Navigator.pushReplacementNamed(context, AppRoutes.home);
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Niepoprawny PIN")),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Wprowadź PIN")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text("Aplikacja została zablokowana po bezczynności."),
// //             SizedBox(height: 12),
// //             TextField(
// //               controller: _pinController,
// //               decoration: InputDecoration(labelText: "PIN"),
// //               obscureText: true,
// //               keyboardType: TextInputType.number,
// //             ),
// //             SizedBox(height: 24),
// //             ElevatedButton(
// //               onPressed: _checkPin,
// //               child: Text("Odblokuj"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }






// class _PinCodeWidgetState extends State<PinCodeWidget> {
//   String enteredPin = '';
//   bool isPinVisible = false;
//   int failedAttempts = 0;
//   bool isLocked = false;
//   int lockoutSeconds = 3;
//   Timer? lockoutTimer;

//   void _checkPin() {
//     if (isLocked) return;

//     if (loggedInUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Brak zalogowanego użytkownika")),
//       );
//       Navigator.pushReplacementNamed(context, AppRoutes.login);
//       return;
//     }

//     if (enteredPin == loggedInUser!.pin) {
//       Navigator.pushReplacementNamed(context, AppRoutes.home);
//     } else {
//       failedAttempts++;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Niepoprawny PIN")),
//       );

//       if (failedAttempts >= 3) {
//         _startLockout();
//       }
//     }
//   }

//   void _startLockout() {
//     setState(() {
//       isLocked = true;
//       failedAttempts = 0; // Reset failed attempts after lockout starts
//     });

//     lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (lockoutSeconds > 1) {
//           lockoutSeconds--;
//         } else {
//           lockoutTimer?.cancel();
//           lockoutTimer = null;
//           isLocked = false;
//           lockoutSeconds = 3; // Reset lockout timer
//         }
//       });
//     });
//   }

//   Widget numButton(int number) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16),
//       child: TextButton(
//         onPressed: isLocked
//             ? null
//             : () {
//                 setState(() {
//                   if (enteredPin.length < 4) {
//                     enteredPin += number.toString();
//                   }
//                 });
//               },
//         child: Text(
//           number.toString(),
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           physics: const BouncingScrollPhysics(),
//           children: [
//             const Center(
//               child: Text(
//                 'Wprowadź Pin',
//                 style: TextStyle(
//                   fontSize: 32,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 50),

//             /// PIN code area
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 4,
//                 (index) {
//                   return Container(
//                     margin: const EdgeInsets.all(6.0),
//                     width: isPinVisible ? 50 : 16,
//                     height: isPinVisible ? 50 : 16,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(6.0),
//                       color: index < enteredPin.length
//                           ? isPinVisible
//                               ? Colors.green
//                               : CupertinoColors.activeBlue
//                           : CupertinoColors.activeBlue.withOpacity(0.1),
//                     ),
//                     child: isPinVisible && index < enteredPin.length
//                         ? Center(
//                             child: Text(
//                               enteredPin[index],
//                               style: const TextStyle(
//                                 fontSize: 17,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           )
//                         : null,
//                   );
//                 },
//               ),
//             ),

//             /// Visibility toggle button
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   isPinVisible = !isPinVisible;
//                 });
//               },
//               icon: Icon(
//                 isPinVisible ? Icons.visibility_off : Icons.visibility,
//               ),
//             ),

//             SizedBox(height: isPinVisible ? 50.0 : 8.0),

//             /// Digits
//             for (var i = 0; i < 3; i++)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: List.generate(
//                     3,
//                     (index) => numButton(1 + 3 * i + index),
//                   ).toList(),
//                 ),
//               ),

//             /// 0 digit with back remove
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const TextButton(onPressed: null, child: SizedBox()),
//                   numButton(0),
//                   TextButton(
//                     onPressed: isLocked
//                         ? null
//                         : () {
//                             setState(
//                               () {
//                                 if (enteredPin.isNotEmpty) {
//                                   enteredPin = enteredPin.substring(
//                                       0, enteredPin.length - 1);
//                                 }
//                               },
//                             );
//                           },
//                     child: const Icon(
//                       Icons.backspace,
//                       color: Colors.black,
//                       size: 24,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// Reset button
//             TextButton(
//               onPressed: isLocked
//                   ? null
//                   : () {
//                       setState(() {
//                         enteredPin = '';
//                       });
//                     },
//               child: const Text(
//                 'Reset',
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.black,
//                 ),
//               ),
//             ),

//             /// Unlock button
//             TextButton(
//               onPressed: _checkPin,
//               child: Text(
//                 'Odblokuj',
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.black,
//                 ),
//               ),
//             ),

//             /// Lockout timer
//             if (isLocked)
//               Center(
//                 child: Text(
//                   'Zablokowane na $lockoutSeconds sekundy',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     lockoutTimer?.cancel();
//     super.dispose();
//   }
// }