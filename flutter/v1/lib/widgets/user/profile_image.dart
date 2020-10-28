import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/spinner.dart';

class ProfileImage extends StatelessWidget {
  final double size;
  final Function onTap;

  ProfileImage({this.size = 128, this.onTap()});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: StreamBuilder(
            stream: ff.authStateChanges,
            builder: (context, snapshot) {
              if (ff.user.photoURL == null) {
                return CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: size,
                  child: Icon(
                    Icons.person,
                    size: Space.xxxl,
                    color: Colors.grey[300],
                  ),
                );
              }
              return CachedNetworkImage(
                imageUrl: ff.user.photoURL,
                placeholder: (context, url) => CommonSpinner(),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: size,
                  child: Icon(
                    Icons.error,
                    size: Space.xxxl,
                    color: Colors.grey[300],
                  ),
                ),
                imageBuilder: (context, provider) {
                  return CircleAvatar(
                    backgroundImage: provider,
                    radius: size,
                  );
                },
              );
            }),

        // GetBuilder<UserController>(
        //   builder: (user) {
        //     return user.photoUrl != null
        //         ? CachedNetworkImage(
        //             imageUrl: user.photoUrl,
        //             placeholder: (context, url) => CommonSpinner(),
        //             errorWidget: (context, url, error) => CircleAvatar(
        //               backgroundColor: Colors.grey,
        //               radius: size,
        //               child: Icon(
        //                 Icons.error,
        //                 size: Space.xxxl,
        //                 color: Colors.grey[300],
        //               ),
        //             ),
        //             imageBuilder: (context, provider) {
        //               return CircleAvatar(
        //                 backgroundImage: provider,
        //                 radius: size,
        //               );
        //             },
        //           )
        //         : CircleAvatar(
        //             backgroundColor: Colors.grey,
        //             radius: size,
        //             child: Icon(
        //               Icons.person,
        //               size: Space.xxxl,
        //               color: Colors.grey[300],
        //             ),
        //           );
        //   },
        // ),
      ),
      onTap: onTap,
    );
  }
}
