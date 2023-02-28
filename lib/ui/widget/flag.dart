import 'package:flutter/cupertino.dart';

class Flag extends StatelessWidget {
  final String code;
  final double? height;
  final double? width;
  final double borderRadius;
  final bool square;

  const Flag({required this.code, this.height, this.width, super.key, 
    this.borderRadius=0, this.square=true
});
  
  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset("assets/flags/${square ? "1x1" : "4x3"}/$code.png", height: height, width: width, fit: BoxFit.cover,);

    if (borderRadius <= 0) return image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image);
  }
}