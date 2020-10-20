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
          return user.photoUrl != null
              ? CachedNetworkImage(
                  width: size,
                  height: size,
                  imageUrl: user.photoUrl,
                  placeholder: (context, url) => CommonSpinner(),
                  imageBuilder: (context, provider) {
                    return CircleAvatar(
                        backgroundImage: provider, radius: size);
                  },
                  errorWidget: (context, url, error) => Icon(Icons.error),
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
