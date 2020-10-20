import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/widgets/spinner.dart';

class ProfileImage extends StatelessWidget {
  final double size;

  ProfileImage({this.size = 128});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GetBuilder<UserController>(
        builder: (user) {
          return CachedNetworkImage(
            width: size,
            height: size,
            imageUrl: user.photoUrl,
            placeholder: (context, url) => CommonSpinner(),
            imageBuilder: (context, provider) {
              return CircleAvatar(backgroundImage: provider, radius: size * 2);
            },
            errorWidget: (context, url, error) => Icon(Icons.error),
          );
        },
      ),
    );
  }
}
