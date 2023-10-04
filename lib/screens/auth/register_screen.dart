import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilayki/screens/auth/email_verification_screen.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/user/user_bloc.dart';
import '../../models/user.dart';
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
  XFile? _pfp;
  XFile? _idCard;
  ImageSource? _imageSource;
  final _imagePicker = ImagePicker();

  // Text Field Controllers
  City? _city;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userBloc = context.read<UserBloc>();

    /* Used for padding for fields */
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        // In case of error
        switch (state.state) {
          case UserStates.registered:
            // pop of progress indicator
            Navigator.of(context).pop();
            // and push the screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const EmailVerificationScreen()),
            );
            break;

          case UserStates.error:
            // In case of error pop the routes (which will contain progress indicator mostly)
            // until login screen and show the snack bar with the error
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.error!.message!,
                textAlign: TextAlign.center,
              ),
            ));
            break;
          case UserStates.processing:
            // Show the Dialog presenting progress indicator
            Navigator.of(context).push(
              DialogRoute(
                barrierDismissible: false,
                context: context,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Ilayki', style: GoogleFonts.kaushanScript()),
            centerTitle: true,
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
                  /// Name
                  SizedBox(height: 172.h),
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.fullName),
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

                  /// Gender
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _genderController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.gender),
                    ),
                  ),

                  /// Phone Number
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.phoneNumber),
                    ),
                  ),

                  /// address
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.address),
                    ),
                  ),

                  /// city
                  SizedBox(height: 24.h),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.city),
                    ),
                    items: cities
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (e) => setState(() => _city = e),
                    value: _city,
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
                      label:
                          Text(AppLocalizations.of(context)!.confirmPassword),
                    ),
                  ),

                  SizedBox(height: 64.h),

                  /* Profile Picture */
                  /* Title of section for Selecting an Image */
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 64.0.sp),
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.addAProfilePicture,
                      style: TextStyle(fontSize: 64.sp),
                    ),
                  ),

                  /* Image Container */
                  GestureDetector(
                    /* image_picker */
                    onTap: () => _pickImage("pfp"),
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
                        image: _pfp != null
                            ? DecorationImage(
                                image: FileImage(
                                  File(_pfp!.path),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.all(1),
                      width: 128.spMax,
                      height: 128.spMax,
                      /* Picture Update */
                      child: _pfp == null
                          ? Text(
                              AppLocalizations.of(context)!.tapHereToAddPicture,
                              textAlign: TextAlign.center,
                            )
                          : null,
                    ),
                  ),
                  /* Hint for Changing image after Selection */
                  if (_pfp != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 64.0.sp),
                      child: Text(
                        AppLocalizations.of(context)!
                            .tapOnTheImageAgainToChange,
                        style: TextStyle(
                          fontSize: 48.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  SizedBox(height: 64.h),

                  /* Profile Picture */
                  /* Title of section for Selecting an Image */
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 64.0.sp),
                    child: Text(
                      AppLocalizations.of(context)!.addYourIdCardPicture,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 64.sp),
                    ),
                  ),

                  /* Image Container */
                  GestureDetector(
                    /* image_picker */
                    onTap: () => _pickImage("idCard"),
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
                        image: _idCard != null
                            ? DecorationImage(
                                image: FileImage(
                                  File(_idCard!.path),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.all(1),
                      width: 128.spMax,
                      height: 128.spMax,
                      /* Picture Update */
                      child: _idCard == null
                          ? Text(
                              AppLocalizations.of(context)!.tapHereToAddPicture,
                              textAlign: TextAlign.center,
                            )
                          : null,
                    ),
                  ),
                  /* Hint for Changing image after Selection */
                  if (_idCard != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 64.0.sp),
                      child: Text(
                        AppLocalizations.of(context)!
                            .tapOnTheImageAgainToChange,
                        style: TextStyle(
                          fontSize: 48.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  // Register Button
                  SizedBox(height: 96.h),
                  Text(
                    AppLocalizations.of(context)!.registerAs,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  SizedBox(height: 48.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          /* If any of the fields are empty */
                          if (_nameController.text.isEmpty ||
                              _emailController.text.isEmpty ||
                              _passwordController.text.isEmpty ||
                              _genderController.text.isEmpty ||
                              _addressController.text.isEmpty ||
                              _phoneNumberController.text.isEmpty ||
                              _city == null ||
                              _idCard == null ||
                              _pfp == null) {
                            /* else show the snackbar saying passwords dont match */
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!
                                      .fillAllFieldsAndImage,
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
                                fullName: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                gender: _genderController.text.trim(),
                                address: _addressController.text.trim(),
                                city: _city.toString(),
                                phoneNumber: _phoneNumberController.text.trim(),
                                xFile: _pfp!,
                                idCard: _idCard!,
                                role: UserRoles.customer,
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          elevation: 4,
                        ),
                        child: Text(AppLocalizations.of(context)!.customer),
                      ),
                      SizedBox(width: 96.h),
                      ElevatedButton(
                        onPressed: () {
                          /* If any of the fields are empty */
                          if (_nameController.text.isEmpty ||
                              _emailController.text.isEmpty ||
                              _passwordController.text.isEmpty ||
                              _genderController.text.isEmpty ||
                              _addressController.text.isEmpty ||
                              _phoneNumberController.text.isEmpty ||
                              _city == null ||
                              _idCard == null ||
                              _pfp == null) {
                            /* else show the snackbar saying passwords dont match */
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!
                                      .fillAllFieldsAndImage,
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
                                fullName: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                gender: _genderController.text.trim(),
                                address: _addressController.text.trim(),
                                city: _city.toString(),
                                phoneNumber: _phoneNumberController.text.trim(),
                                xFile: _pfp!,
                                idCard: _idCard!,
                                role: UserRoles.seller,
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          elevation: 4,
                        ),
                        child: Text(AppLocalizations.of(context)!.seller),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          persistentFooterButtons: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.alreadyRegistered),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .popAndPushNamed(LoginScreen.routeName),
                  child: Text(AppLocalizations.of(context)!.signIn),
                )
              ],
            ),
          ],
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              onPressed: () =>
                  ScaffoldMessenger.of(context).clearMaterialBanners(),
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
  void _pickImage(String dest) async {
    // Pick the Image Source
    await _pickImageSource();

    // Check if Image Source is Null, Cancel the Operation
    if (_validateImageSource()) {
      /* Else Pick the Image File */
      _imagePicker.pickImage(source: _imageSource!).then((value) {
        if (value != null) {
          setState(() {
            dest == "idCard" ? _idCard = value : _pfp = value;
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
