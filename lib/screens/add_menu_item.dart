import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:image_picker/image_picker.dart';

class AddMenuItemScreen extends StatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  XFile? _xFile;
  ImageSource? _imageSource;
  final _imagePicker = ImagePicker();

  /* Controllers */
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemDescController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addMenuItem),
      ),

      /* Body of the Screen containing the form which contains two textfields and an Image Container */
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.spMax),
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
          ],
        ),
      ),
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
