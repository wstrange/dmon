import 'package:flutter/material.dart';
import 'service_list_widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: ServiceListWidget(),
      ),
    );
  }
}
