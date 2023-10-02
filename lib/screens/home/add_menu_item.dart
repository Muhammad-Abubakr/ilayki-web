import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../../models/item.dart';

class AddMenuItemScreen extends StatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  /* Firebase Realtime database */
  final database = FirebaseDatabase.instance.ref();
  final storage = FirebaseStorage.instance.ref();

  /* Image Picker */
  Uint8List? _xFile;
/*
  XFile? _xFile;
  ImageSource? _imageSource;
  final _imagePicker = ImagePicker();
*/

  /* Controllers */
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemDescController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /* Getting the UID of the user to store it's created items*/
    final user = context.watch<UserBloc>().state.user;

    /* Storing the Item */
    final itemRef = database.child('items/${user!.uid}');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addMenuItem),
        actions: [
          /* Action Call to Save item */
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: Text(AppLocalizations.of(context)!.save),
            onPressed: () {
              /* Basic validation */
              if (_itemNameController.text.isEmpty ||
                  _itemDescController.text.isEmpty ||
                  _itemPriceController.text.isEmpty ||
                  _xFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.fillAllFieldsAndImage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                // if basic valids pass
                try {
                  (() async {
                    /* Storing the image */
                    /// Getting the reference
                    late final imageRef =
                        storage.child('items/${user.uid}/${itemRef.key}');

                    /// for image of the item
                    await imageRef.putData(_xFile!);

                    /// for item as a whole
                    /* first get a ref to set the new item */
                    final newItemRef = itemRef.push();

                    /* Set the new item on the newly create ref */
                    await newItemRef.set(Item(
                      owner: user.uid,
                      id: newItemRef.path.split('/').last,
                      name: _itemNameController.text,
                      price: double.parse(_itemPriceController.text),
                      description: _itemDescController.text,
                      ratingCount: 0,
                      image: await imageRef
                          .getDownloadURL(), // arrives ones we upload the picture to the storage
                    ).toJson());
                  })();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.itemAddedSuccessfully,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                  // Pop the add new item
                  Navigator.of(context).pop();

                  /* On Exception */
                } on FirebaseException catch (e) {
                  if (kDebugMode) {
                    print(
                        'Error Occured while talking to FirebaseStorage or FirebaseDatabase: $e');
                  }
                }
              }
            },
          ),
        ],
      ),

      /* Body of the Screen containing the form which contains two textfields and an Image Container */
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24.spMax, horizontal: 0.2.sw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* TextField for Item Name */
            TextField(
              controller: _itemNameController,
              maxLength: 32,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.edit),
                label: Text(AppLocalizations.of(context)!.itemName),
              ),
            ),
            SizedBox(height: 20.sp),

            /* TextField for Item Price */
            TextField(
              controller: _itemPriceController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.money),
                label: Text(AppLocalizations.of(context)!.price),
              ),
            ),
            SizedBox(height: 20.sp),

            /* TextField for Item description */
            TextField(
              controller: _itemDescController,
              maxLength: 256,
              maxLines: 6,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.description),
                label: Text(AppLocalizations.of(context)!.description),
              ),
            ),

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
                padding: EdgeInsets.all(4.spMax),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(24.r)),
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    image: _xFile != null
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.memory(
                              _xFile!,
                              fit: BoxFit.cover,
                            ).image,
                          )
                        : null),
                width: 128.spMax,
                height: 128.spMax,
                /* Picture Update */
                child: _xFile == null
                    ? Text(
                        AppLocalizations.of(context)!.tapHereToAddPicture,
                        textAlign: TextAlign.center,
                      )
                    : null,
              ),
            ),
            /* Hint for Changing image after Selection */
            if (_xFile != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 64.0.sp),
                child: Text(
                  AppLocalizations.of(context)!.tapOnTheImageAgainToChange,
                  style: TextStyle(
                    fontSize: 48.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePickerWeb.getImageAsBytes();
    if (pickedImage != null) {
      setState(() {
        _xFile = pickedImage;
      });
    }
  }

/* No Image Source was specified. This can happen when the Modal Bottom Sheet was dismissed
without providing the _imageSource value by tapping on either of the
two sources: Camera or Gallery */ /*

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

*/ /* Shows a SnackBar that displays that No image was picked or Captured by the User */ /*
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

  */ /* Image Picker Utilizer */ /*
  void _pickImage() async {
    // Pick the Image Source
    await _pickImageSource();

    // Check if Image Source is Null, Cancel the Operation
    if (_validateImageSource()) {
      */ /* Else Pick the Image File */ /*
      _imagePicker.pickImage(source: _imageSource!).then((value) {
        if (value != null) {
          setState(() {
            _xFile = value;
          });
        } else {
          */ /* Show the SnackBar telling the user that no image was selected */ /*
          _noImagePickedOrCaptured();
        }
        */ /* Set the _imageSource to be Null */ /*
        _imageSource = null;
      });
    }
  }*/
}
