import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/user/user_bloc.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  // route name
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /* Image Picker */
  XFile? _xFile;
  ImageSource? _imageSource;
  final _imagePicker = ImagePicker();

  // Text Field Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userBloc = context.read<UserBloc>();

    /* Used for padding for fields */
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        // In case of error
        switch (state.state) {
          case UserStates.error:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.error!.message!,
                textAlign: TextAlign.center,
              ),
            ));
            break;
          case UserStates.processing:
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ));
            break;
          case UserStates.registered:
            Navigator.of(context).popUntil(ModalRoute.withName(LoginScreen.routeName));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'User successfully registered. Please Login',
                textAlign: TextAlign.center,
              ),
            ));
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.registerHere),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: !isLandscape ? 0.08.sw : 0.3.sw,
                vertical: 128.h,
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.register,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),

                  /* Text fields */
                  /// Email
                  SizedBox(height: 172.h),
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.displayName),
                    ),
                  ),

                  /// Email
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.email),
                    ),
                  ),

                  /// Password
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.password),
                    ),
                  ),

                  /// Confirm Password
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.confirmPassword),
                    ),
                  ),

                  SizedBox(height: 64.h),

                  /* Profile Picture */
                  /* Title of section for Selecting an Image */
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 64.0.sp),
                    child: Text(
                      AppLocalizations.of(context)!.addAnImage,
                      style: TextStyle(fontSize: 64.sp),
                    ),
                  ),

                  /* Image Container */
                  GestureDetector(
                    /* image_picker */
                    onTap: () => _pickImage(),
                    /* Container */
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(24.r)),
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.all(1),
                      width: 128.spMax,
                      height: 128.spMax,
                      /* Picture Update */
                      child: _xFile == null
                          ? Text(
                              AppLocalizations.of(context)!.tapHereToAddPicture,
                              textAlign: TextAlign.center,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: Image(
                                image: FileImage(File(_xFile!.path)),
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                  ),
                  /* Hint for Changing image after Selection */
                  if (_xFile != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 64.0.sp),
                      child: Text(
                        "Tip: Tap on the Image again to change",
                        style: TextStyle(
                          fontSize: 48.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  // Register Button
                  SizedBox(height: 96.h),
                  ElevatedButton(
                    onPressed: () {
                      /* If any of the fields are empty */
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _xFile == null) {
                        /* else show the snackbar saying passwords dont match */
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please fill all the fields and select a Profile Image!",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      /* If this fields contain identical passwords Register */
                      else if (_passwordController.text.trim() !=
                          _confirmPasswordController.text.trim()) {
                        /* else show the snackbar saying passwords dont match */
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.passNotMatch,
                            textAlign: TextAlign.center,
                          ),
                        ));
                      } else {
                        userBloc.add(
                          RegisterUserWithEmailAndPassword(
                            displayName: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            xFile: _xFile!,
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      elevation: 4,
                    ),
                    child: Text(AppLocalizations.of(context)!.register),
                  ),
                ],
              ),
            ),
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
          setState(() {
            _xFile = value;
          });
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
