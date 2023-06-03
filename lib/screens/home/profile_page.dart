import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:ilayki/screens/home/add_menu_item.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/items/items_bloc.dart';
import '../../blocs/online/online_cubit.dart';
import '../../blocs/user/user_bloc.dart';
import '../../widgets/item_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ImageSource? _imageSource;
  final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserBloc>().state.user;

    return BlocBuilder<ItemsBloc, ItemsState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.only(right: 0.1.sw, left: 0.1.sw, top: 64.h),
            child: SizedBox(
              height: 1.sh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            // Handler for picking image
                            onTap: () => _pickImage(),

                            // Ternary Operation: image present ? show : show placeholder icon;
                            child: state.user!.photoURL == null
                                ? CircleAvatar(
                                    radius: 196.r,
                                    child: Icon(
                                      Icons.person,
                                      size: 196.r,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    radius: 204.r,
                                    child: CircleAvatar(
                                      radius: 196.r,
                                      // If the photo url of the user in not null ? show the email pfp
                                      backgroundImage:
                                          Image.network(state.user!.photoURL!).image,
                                    ),
                                  ),
                          ),
                          BlocBuilder<OnlineCubit, OnlineState>(
                              builder: (context, onlineState) {
                            return Container(
                              margin: EdgeInsets.only(right: 16.spMax),
                              child: CircleAvatar(
                                radius: 42.r,
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                child: CircleAvatar(
                                  radius: 32.r,
                                  backgroundColor:
                                      onlineState.onlineUsers.contains(state.user!.uid)
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                  /* User Title */
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Text(
                      // If the display name of the user is null? show placeholder name
                      user!.displayName == null || user.displayName!.isEmpty
                          ? AppLocalizations.of(context)!.store
                          // else show real name
                          : user.displayName!,
                      // name styling / configuration
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 72.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  /* User Menu Label */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.menu,
                        style: TextStyle(
                          fontSize: 48.sp,
                        ),
                      ),
                      SizedBox(
                        width: 600.w,
                        child: Text(
                          AppLocalizations.of(context)!.tipProfilePage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 36.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  /* User Menu List */
                  if (state.items.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 200.h),
                      child: Text(AppLocalizations.of(context)!.addSomethingToShowHere),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (_, idx) => ItemWidget(
                          item: state.items[idx],
                        ),
                        separatorBuilder: (_, idx) => const Divider(),
                        itemCount: state.items.length,
                      ),
                    ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddMenuItemScreen()),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            elevation: 4,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

/* Displays a Modal Bootm Sheet with Two Options for _imageSource required by ImagePicker in a Row  */
  Future _pickImageSource() async {
    return await showModalBottomSheet(
      constraints: BoxConstraints.tight(Size.fromHeight(256.h)),
      context: context,
      builder: (bottomSheetContext) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: () {
                _imageSource = ImageSource.camera;
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.camera),
              label: const Text("Camera"),
            ),
            const VerticalDivider(),
            TextButton.icon(
              onPressed: () {
                _imageSource = ImageSource.gallery;
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.photo_album),
              label: const Text("Gallery"),
            )
          ],
        ),
      ),
    );
  }

/* No Image Source was specified. This can happen when the Modal Bottom Sheet was dismissed 
without providing the _imageSource value by tapping on either of the 
two sources: Camera or Gallery */
  bool _validateImageSource() {
    if (_imageSource == null) {
      ScaffoldMessenger.of(context).removeCurrentMaterialBanner();

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          margin: const EdgeInsets.only(bottom: 16.0),
          content: Text(AppLocalizations.of(context)!.operationCancelled),
          actions: [
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.dismiss),
              onPressed: () => ScaffoldMessenger.of(context).clearMaterialBanners(),
            )
          ],
        ),
      );

      return false;
    }
    return true;
  }

/* Shows a SnackBar that displays that No image was picked or Captured by the User */
  void _noImagePickedOrCaptured() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.noImageSelected),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          onPressed: () => ScaffoldMessenger.of(context).clearSnackBars(),
        ),
      ),
    );
  }

  /* Image Picker Utilizer */
  void _pickImage() async {
    // Pick the Image Source
    await _pickImageSource();

    // Check if Image Source is Null, Cancel the Operation
    if (_validateImageSource()) {
      /* Else Pick the Image File */
      _imagePicker.pickImage(source: _imageSource!).then((value) {
        if (value != null) {
          /* Update the User Profile Picture */
          context.read<UserBloc>().add(UserPfpUpdate(xFile: value));
        } else {
          /* Show the SnackBar telling the user that no image was selected */
          _noImagePickedOrCaptured();
        }
        /* Set the _imageSource to be Null */
        _imageSource = null;
      });
    }
  }
}
