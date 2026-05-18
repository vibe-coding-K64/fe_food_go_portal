import 'package:flutter/material.dart'; 
 
class LoginPage extends StatefulWidget { 
  const LoginPage({super.key}); 
 
  @override 
  State<LoginPage> createState() => _LoginPageState(); 
} 
 
class _LoginPageState extends State<LoginPage> { 
  final usernameController = TextEditingController(); 
  final passwordController = TextEditingController(); 
  bool _isObscure = true; 
 
  @override 
  Widget build(BuildContext context) { 

 
    return Scaffold( 
      body: Container( 
        // Tạo nền Gradient chuyển màu sinh động 
        decoration: BoxDecoration( 
          gradient: LinearGradient( 
            begin: Alignment.topLeft, 
            end: Alignment.bottomRight, 
            colors: [Colors.blue.shade900, Colors.teal.shade400], 
          ), 
        ), 
        child: Center( 
          child: SingleChildScrollView( 
            child: TweenAnimationBuilder( 
              duration: const Duration(milliseconds: 800), 
              tween: Tween<double>(begin: 0, end: 1), 
              builder: (context, double value, child) { 
                return Opacity( 
                  opacity: value, 
                  child: Transform.translate( 
                    offset: Offset(0, 50 * (1 - value)), 
                    child: child, 
                  ), 
                ); 
              }, 
              child: Container(
                  width: 350, 
                padding: const EdgeInsets.all(30), 
                decoration: BoxDecoration( 
                  color: Colors.white.withOpacity(0.9), 
                  borderRadius: BorderRadius.circular(25), 
                  boxShadow: [ 
                    BoxShadow( 
                      color: Colors.black.withOpacity(0.2), 
                      blurRadius: 20, 
                      spreadRadius: 5, 
                    ), 
                  ], 
                ), 
                child: Column( 
                  mainAxisSize: MainAxisSize.min, 
                  children: [ 
                    // Icon đại diện cho ngành Y tế/OCR 
                    Container( 
                      padding: const EdgeInsets.all(15), 
                      decoration: BoxDecoration( 
                        color: Colors.orange.shade50, 
                        shape: BoxShape.circle, 
                      ), 
                      child: Icon( 
                        Icons.local_pizza_rounded, 
                        size: 50, 
                        color: Colors.orange.shade800, 
                      ), 
                    ), 
                    const SizedBox(height: 20), 
                    const Text( 
                      "ADMIN LOGIN", 
                      style: TextStyle( 
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.5, 
                        color: Colors.black87, 
                      ), 
                    ), 
                    const SizedBox(height: 10), 
                    const Text( 
                      "Hệ thống quản trị cửa hàng Pizza", 
                      style: TextStyle(color: Colors.grey), 
                    ), 
                    const SizedBox(height: 30), 
 
                    // TextField Tên đăng nhập 
                    TextField( 
                      controller: usernameController, 
                      decoration: InputDecoration( prefixIcon: const Icon(Icons.person_outline), 
                        labelText: "Username", 
                        filled: true, 
                        fillColor: Colors.grey.shade100, 
                        border: OutlineInputBorder( 
                          borderRadius: BorderRadius.circular(15), 
                          borderSide: BorderSide.none, 
                        ), 
                      ), 
                    ), 
                    const SizedBox(height: 20), 
 
                    // TextField Mật khẩu 
                    TextField( 
                      controller: passwordController, 
                      obscureText: _isObscure, 
                      decoration: InputDecoration( 
                        prefixIcon: const Icon(Icons.lock_outline), 
                        suffixIcon: IconButton( 
                          icon: Icon( 
                            _isObscure 
                                ? Icons.visibility 
                                : Icons.visibility_off, 
                          ), 
                          onPressed: () => 
                              setState(() => _isObscure = !_isObscure), 
                        ), 
                        labelText: "Password", 
                        filled: true, 
                        fillColor: Colors.grey.shade100, 
                        border: OutlineInputBorder( 
                          borderRadius: BorderRadius.circular(15), 
                          borderSide: BorderSide.none, 
                        ), 
                      ), 
                    ), 
                    const SizedBox(height: 30), 
 
                    // Nút Login với hiệu ứng Gradient 
                    SizedBox( 
                      width: double.infinity, 
                      height: 55, 
                      child: ElevatedButton( 
                        onPressed: () { 
                          if (usernameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar( 
                              SnackBar( 
                                backgroundColor: Colors.redAccent, 
                                behavior: SnackBarBehavior.floating, 
                                shape: RoundedRectangleBorder( 
                                  borderRadius: BorderRadius.circular(10), 
                                ), 
                                content: const Row( 
                                  children: [ 
                                    Icon( 
                                      Icons.error_outline, 
                                      color: Colors.white, 
                                    ), 
                                    SizedBox(width: 10), 
                                    Text("Vui lòng nhập tài khoản"), 
                                  ], 
                                ), 
                              ), 
                            ); 
                          } else {
                            debugPrint("Đăng nhập thành công!");
                          }
                        }, 
                        style: ElevatedButton.styleFrom( 
                          backgroundColor: Colors.orange.shade800, 
                          foregroundColor: Colors.white, 
                          shape: RoundedRectangleBorder( 
                            borderRadius: BorderRadius.circular(15), 
                          ), 
                          elevation: 5, 
                        ), 
                        child: const Text( 
                          "ĐĂNG NHẬP", 
                          style: TextStyle( 
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                          ), 
                        ), 
                      ), 
                    ), 
                    const SizedBox(height: 20), 
                    TextButton( 
                      onPressed: () {}, 
                      child: const Text("Quên mật khẩu?"), 
                    ), 
                  ], 
                ), 
              ), 
            ), 
          ), 
        ), 
  ), 
    ); 
  } 
} 