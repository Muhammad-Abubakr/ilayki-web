import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../../app.dart';
import '../../blocs/items/items_bloc.dart';
import '../../blocs/orders/orders_cubit.dart';
import '../../blocs/requests/requests_cubit.dart';
import '../../blocs/sales/sales_cubit.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/userchat/userchat_cubit.dart';
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
/*  XFile? _xFile;
  ImageSource? _imageSource;
  final _imagePicker = ImagePicker();*/
  Uint8List? _imageBytes;

  // Text Field Controllers
  final TextEditingController _nameController = TextEditingController();
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
            /* Initialize the requests for current user */
            context.read<RequestsCubit>().initialize();

            /* Initialize the orders for current user */
            context.read<OrdersCubit>().initialize();

            /* Initialize the sales for current user */
            context.read<SalesCubit>().initialize();

            /* Initialize the user chats */
            context.read<UserchatCubit>().intialize();

            /* Fetch the Items */
            context
                .read<ItemsBloc>()
                .add(ActivateItemsListener(userBloc: context.read<UserBloc>()));

            // Pop the progress indicator
            Navigator.of(context).pop();
            // and push the screen
            Navigator.of(context).popAndPushNamed(App.routeName);
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
            title: Text('Ilayki',
                style: GoogleFonts.kaushanScript(fontSize: 32.spMax)),
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: !isLandscape ? 0.08.sw : 0.35.sw,
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
                        image: _imageBytes != null
                            ? DecorationImage(
                                image: Image.memory(_imageBytes!).image,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.all(1),
                      width: 128.spMax,
                      height: 128.spMax,
                      /* Picture Update */
                      child: _imageBytes == null
                          ? Text(
                              AppLocalizations.of(context)!.tapHereToAddPicture,
                              textAlign: TextAlign.center,
                            )
                          : null,
                    ),
                  ),
                  /* Hint for Changing image after Selection */
                  if (_imageBytes != null)
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
                              _imageBytes == null) {
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
                                displayName: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                image: _imageBytes!,
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
                              _imageBytes == null) {
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
                                displayName: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                image: _imageBytes!,
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

  Future<void> _pickImage() async {
    final pickedImage = await ImagePickerWeb.getImageAsBytes();
    if (pickedImage != null) {
      setState(() {
        _imageBytes = pickedImage;
      });
    }
  }
}
