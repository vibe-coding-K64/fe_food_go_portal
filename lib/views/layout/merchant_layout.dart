import 'package:flutter/material.dart'; 
import 'sidebar.dart'; 
import 'merchant_appbar.dart'; 
 
class MerchantLayout extends StatefulWidget { 
  final Widget child; 
  final Function(String) onNavigate; 
  final String currentRoute; 
  const MerchantLayout({ 
    super.key, 
    required this.child, 
    required this.onNavigate, 
    required this.currentRoute, 
  }); 
  @override 
  State<MerchantLayout> createState() => _MerchantLayoutState(); 
} 
 
class _MerchantLayoutState extends State<MerchantLayout> { 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      body: Row( 
        children: [ 
          Sidebar(
            onNavigate: widget.onNavigate, 
            currentRoute: widget.currentRoute, 
          ), 
          Expanded( 
            child: Column(
              children: [
                SizedBox(
                  height: 57,
                  child: MerchantAppBar(onNavigate: widget.onNavigate),
                ),
                Expanded(
                  child: Container( 
                    color: Colors.grey[100], 
                    padding: const EdgeInsets.all(24), 
                    child: widget.child, 
                  ), 
                ),
              ],
            ), 
          ), 
        ], 
      ), 
    ); 
  } 
} 