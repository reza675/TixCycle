import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tixcycle/controllers/edit_profile_controller.dart';

const Color c1_cream = Color(0xFFFFF8E2);
const Color c2_lightGreen = Color(0xFFB3CC86);
const Color c3_medGreen = Color(0xFF96AD72);
const Color c4_darkGreen = Color(0xFF3F5135);

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1_cream, c2_lightGreen, c3_medGreen, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: c4_darkGreen),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Edit Profil',
            style: TextStyle(
                color: c4_darkGreen, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  Obx(() => controller.isAdmin.value
                      ? const SizedBox.shrink() 
                      : Column( 
                          children: [
                            _buildSectionTitle("Info Pribadi"),
                            _buildTextFormField(
                              controller: controller.nameController,
                              label: "Nama Lengkap",
                              validator: (val) =>
                                  val!.isEmpty ? "Nama tidak boleh kosong" : null,
                            ),
                            _buildTextFormField(
                              controller: controller.genderController,
                              label: "Jenis Kelamin",
                            ),
                            _buildDateField(context),
                            _buildTextFormField(
                              controller: controller.provinceController,
                              label: "Provinsi",
                            ),
                            _buildTextFormField(
                              controller: controller.cityController,
                              label: "Kota / Kabupaten",
                            ),
                            _buildTextFormField(
                              controller: controller.occupationController,
                              label: "Pekerjaan",
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                  ),
                  
                  _buildSectionTitle("Info Akun & Identitas"),
                  _buildPhoneField(), 
                  _buildTextFormField(
                    controller: controller.idTypeController,
                    label: "Tipe ID (KTP/SIM/Paspor)",
                  ),
                   _buildTextFormField(
                    controller: controller.idNumberController,
                    label: "Nomor Identitas",
                    keyboardType: TextInputType.number, 
                  ),
                 
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: c4_darkGreen,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }


  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType, 
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType, 
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: c4_darkGreen, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: c1_cream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller.phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: "Nomor Telepon",
          labelStyle: const TextStyle(
              color: c4_darkGreen, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: c1_cream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('(+62)',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor telepon tidak boleh kosong';
            }
            return null;
          },
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller.birthDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Tanggal Lahir (dd/mm/yyyy)",
          labelStyle: const TextStyle(
              color: c4_darkGreen, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: c1_cream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: const Icon(Icons.calendar_today, color: c4_darkGreen),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            String formattedDate =
                DateFormat('dd/MM/yyyy').format(pickedDate);
            controller.birthDateController.text = formattedDate;
          }
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: c3_medGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "SIMPAN",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ));
  }
}