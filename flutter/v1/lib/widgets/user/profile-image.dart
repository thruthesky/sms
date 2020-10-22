import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/spinner.dart';

class ProfileImage extends StatelessWidget {
  final double size;

  ProfileImage({this.size = 128});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GetBuilder<UserController>(
        builder: (user) {
          print('User photo URL: ${user.photoUrl}');
          return user.photoUrl != null
              ? CachedNetworkImage(
                  imageUrl: user.photoUrl,
                  placeholder: (context, url) => CommonSpinner(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    size: Space.xxxl,
                  ),
                  imageBuilder: (context, provider) {
                    return CircleAvatar(
                      backgroundImage: provider,
                      radius: size,
                    );
                  },
                )
              : CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: size,
                  child: Icon(
                    Icons.person,
                    size: Space.xxxl,
                    color: Colors.grey[300],
                  ),
                );
        },
      ),
    );
  }
}
