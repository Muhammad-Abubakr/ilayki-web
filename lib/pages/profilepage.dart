import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../blocs/authenticate/authenticate_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool editing = false;
  Uint8List? _pfp;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<AuthenticateBloc, AuthenticateState>(
      builder: (context, state) {
        _nameController.value =
            TextEditingValue(text: state.user!.displayName!);
        _emailController.value = TextEditingValue(text: state.user!.email!);

        return Row(
          children: [
            Card(
              elevation: 8,
              child: SizedBox(
                width: max(250, size.width * 0.2),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _pfp != null
                              ? Image.memory(_pfp!, fit: BoxFit.cover)
                              : Image.network(state.user!.photoURL!,
                                  fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 48),
                      if (editing)
                        ElevatedButton(
                          onPressed: () => _pickImage(),
                          child: const Text("Upload a Picture"),
                        ),
                      const SizedBox(height: 48),
                      TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        enabled: editing,
                        decoration: const InputDecoration(
                          label: Text("Name"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: editing,
                        decoration: const InputDecoration(
                          label: Text("Email"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        enabled: editing,
                        decoration: const InputDecoration(
                          label: Text("Update Password"),
                        ),
                      ),
                      const SizedBox(height: 64),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () => setState(() {
                              editing = !editing;
                              _passwordController.clear();
                              _pfp = null;
                            }),
                            child: Text(editing ? "Cancel" : "Edit Profile"),
                          ),
                          if (editing)
                            ElevatedButton(
                              onPressed: () => {},
                              child: const Text("Save"),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  _pickImage() async {
    final picked = await ImagePickerWeb.getImageAsBytes();
    if (picked != null) {
      setState(() => _pfp = picked);
    }
  }
}
