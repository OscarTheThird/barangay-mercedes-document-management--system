import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class ResidentsRecordPage extends StatefulWidget {
  @override
  _ResidentsRecordPageState createState() => _ResidentsRecordPageState();
}

class _ResidentsRecordPageState extends State<ResidentsRecordPage> {
  int _rowsPerPage = 10;
  String _search = '';
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // For web
  bool _isUploading = false;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'firstname': TextEditingController(),
    'middlename': TextEditingController(),
    'lastname': TextEditingController(),
    'suffix': TextEditingController(),
    'birthplace': TextEditingController(),
    'birthday': TextEditingController(),
    'age': TextEditingController(),
    'civilStatus': TextEditingController(),
    'gender': TextEditingController(),
    'purok': TextEditingController(),
    'voterStatus': TextEditingController(),
    'email': TextEditingController(),
    'contact': TextEditingController(),
    'occupation': TextEditingController(),
    'citizenship': TextEditingController(),
    'address': TextEditingController(),
    'householdNo': TextEditingController(),
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.all(32),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Residents Record', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showResidentForm(),
                          icon: Icon(Icons.person_add, color: Colors.white),
                          label: Text('+ Resident'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.file_download, color: Colors.white),
                          label: Text('Export CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Show'),
                        SizedBox(width: 8),
                        DropdownButton<int>(
                          value: _rowsPerPage,
                          items: [10, 25, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                          onChanged: (value) {
                            setState(() {
                              _rowsPerPage = value!;
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        Text('entries'),
                      ],
                    ),
                    Container(
                      width: 220,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _search = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('residents').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No residents found.'));
                    }
                    print('Fetched residents: \\${snapshot.data!.docs.length}');
                    final filteredResidents = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['firstname']?.toLowerCase()?.contains(_search.toLowerCase()) == true ||
                          data['lastname']?.toLowerCase()?.contains(_search.toLowerCase()) == true;
                    }).toList();
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              headingRowColor: MaterialStateProperty.all(Color(0xFFF6F6FA)),
                              dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) return Colors.deepPurple.shade50;
                                return null;
                              }),
                              dividerThickness: 0.5,
                              columns: [
                                DataColumn(label: Text('ID Number', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Purok', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Civil Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Voter Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: List.generate(filteredResidents.take(_rowsPerPage).length, (i) {
                                final doc = filteredResidents[i];
                                final data = doc.data() as Map<String, dynamic>;
                                final isEven = i % 2 == 0;
                                return DataRow(
                                  color: MaterialStateProperty.all(isEven ? Color(0xFFF8F8FA) : Colors.white),
                                  cells: [
                                    DataCell(Text('')), // ID Number (empty for now)
                                    DataCell(
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          (data['firstname'] ?? '') +
                                          (data['middlename'] != null && data['middlename'] != '' ? ' ' + data['middlename'] : '') +
                                          (data['lastname'] != null && data['lastname'] != '' ? ' ' + data['lastname'] : ''),
                                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple.shade900, fontSize: 15),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(data['purok'] ?? '')),
                                    DataCell(Text(data['age']?.toString() ?? '')),
                                    DataCell(Text(data['civilStatus'] ?? '')),
                                    DataCell(Text(data['gender'] ?? '')),
                                    DataCell(Text(data['voterStatus'] ?? '')),
                                    DataCell(_buildStyledActionMenu(context)),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Showing 1 to \\${filteredResidents.length < _rowsPerPage ? filteredResidents.length : _rowsPerPage} of \\${filteredResidents.length} entries'),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    side: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  child: Text('Previous'),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    side: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  child: Text('Next'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledActionMenu(BuildContext context) {
    final GlobalKey actionKey = GlobalKey();
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Listener(
          onPointerDown: (_) => setState(() => isPressed = true),
          onPointerUp: (_) => setState(() => isPressed = false),
          child: ElevatedButton(
            key: actionKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPressed ? Colors.blue.shade800 : Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              textStyle: TextStyle(color: Colors.white),
              disabledBackgroundColor: Colors.blue,
              disabledForegroundColor: Colors.white,
            ),
            onPressed: () {
              final RenderBox button = actionKey.currentContext!.findRenderObject() as RenderBox;
              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
              final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  position.dx,
                  position.dy + button.size.height,
                  overlay.size.width - position.dx - button.size.width,
                  overlay.size.height - position.dy - button.size.height,
                ),
                items: [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [Icon(Icons.edit, color: Colors.green), SizedBox(width: 8), Text('Edit')],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [Icon(Icons.visibility, color: Colors.blue), SizedBox(width: 8), Text('View')],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Remove')],
                    ),
                  ),
                ],
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Action'),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        _selectedImageBytes = result.files.single.bytes;
        print('Selected image bytes: \\${_selectedImageBytes?.length}');
        return _selectedImageBytes;
      }
      return null;
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print('Selected image file: \\${pickedFile.path}');
        return File(pickedFile.path);
      }
      return null;
    }
  }

  Future<String?> uploadImageToCloudinary(dynamic imageFile) async {
    final cloudName = 'dvms81vso';
    final uploadPreset = 'Profile';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;
    if (kIsWeb && imageFile is Uint8List) {
      request.files.add(http.MultipartFile.fromBytes('file', imageFile, filename: 'upload.png'));
    } else if (imageFile is File) {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    } else {
      return null;
    }
    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);
      return resJson['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> saveResidentToFirestore(Map<String, dynamic> residentData) async {
    await FirebaseFirestore.instance.collection('residents').add(residentData);
  }

  void _showResidentForm({Map<String, dynamic>? resident}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 900,
            padding: EdgeInsets.all(0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_add, color: Colors.deepPurple, size: 28),
                        SizedBox(width: 12),
                        Text(
                          resident == null ? 'Add Resident' : 'Edit Resident',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar and photo upload area
                          Container(
                            width: 220,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: kIsWeb
                                          ? (_selectedImageBytes != null ? MemoryImage(_selectedImageBytes!) : null)
                                          : (_selectedImage != null ? FileImage(_selectedImage!) : null),
                                      child: (_selectedImage == null && _selectedImageBytes == null)
                                          ? Icon(Icons.person, size: 80, color: Colors.grey)
                                          : null,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 18),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    var img = await pickImage();
                                    setState(() {
                                      if (kIsWeb) {
                                        _selectedImageBytes = img;
                                        _selectedImage = null;
                                        print('Selected image bytes: \\${_selectedImageBytes?.length}');
                                      } else {
                                        _selectedImage = img;
                                        _selectedImageBytes = null;
                                        print('Selected image file: \\${_selectedImage?.path}');
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.upload_file, color: Colors.deepPurple),
                                  label: Text('Upload Photo', style: TextStyle(color: Colors.deepPurple)),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    side: BorderSide(color: Colors.deepPurple),
                                  ),
                                ),
                                if (_selectedImage != null || _selectedImageBytes != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Picture selected!',
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                SizedBox(height: 24),
                                Divider(),
                                SizedBox(height: 8),
                                _residentTextField('Enter Household No.', controller: _controllers['householdNo']),
                              ],
                            ),
                          ),
                          SizedBox(width: 32),
                          // Main form fields
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _residentTextField('Enter Firstname', controller: _controllers['firstname'])),
                                    SizedBox(width: 8),
                                    Expanded(child: _residentTextField('Enter Middlename', controller: _controllers['middlename'])),
                                    SizedBox(width: 8),
                                    Expanded(child: _residentTextField('Enter Lastname', controller: _controllers['lastname'])),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Flexible(flex: 4, child: _residentTextField('Enter Suffix (Optional)', controller: _controllers['suffix'], required: false)),
                                    SizedBox(width: 8),
                                    Flexible(flex: 5, child: _residentTextField('Enter Birthplace', controller: _controllers['birthplace'])),
                                    SizedBox(width: 8),
                                    Flexible(flex: 5, child: _residentTextField('dd/mm/yyyy', icon: Icons.calendar_today, controller: _controllers['birthday'])),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: _residentTextField('Enter Age', controller: _controllers['age'])),
                                    SizedBox(width: 8),
                                    Expanded(child: _residentDropdown(['Single', 'Married', 'Widowed', 'Separated'], 'Select Civil Status', controller: _controllers['civilStatus'])),
                                    SizedBox(width: 8),
                                    Expanded(child: _residentDropdown(['Male', 'Female'], 'Select Gender', controller: _controllers['gender'])),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: _residentDropdown(['Purok 1', 'Purok 2', 'Purok 3'], 'Select Purok Name', controller: _controllers['purok'])),
                                    SizedBox(width: 8),
                                    Expanded(child: _residentDropdown(['Yes', 'No'], 'Select Voters Status', controller: _controllers['voterStatus'])),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: _residentTextField('Enter Email', controller: _controllers['email'])),
                                    SizedBox(width: 8),
                                    Expanded(child: _residentTextField('Enter Contact Number', controller: _controllers['contact'])),
                                    SizedBox(width: 8),
                                    Expanded(child: _residentTextField('Enter Occupation', controller: _controllers['occupation'])),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: _residentTextField('Enter Citizenship', controller: _controllers['citizenship'])),
                                  ],
                                ),
                                SizedBox(height: 12),
                                _residentTextField('Enter Address', controller: _controllers['address']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, thickness: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isUploading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() { _isUploading = true; });
                              String? imageUrl;
                              if (_selectedImage != null || _selectedImageBytes != null) {
                                imageUrl = await uploadImageToCloudinary(kIsWeb ? _selectedImageBytes : _selectedImage);
                              }
                              Map<String, dynamic> residentData = {
                                'firstname': _controllers['firstname']!.text,
                                'middlename': _controllers['middlename']!.text,
                                'lastname': _controllers['lastname']!.text,
                                'suffix': _controllers['suffix']!.text,
                                'birthplace': _controllers['birthplace']!.text,
                                'birthday': _controllers['birthday']!.text,
                                'age': _controllers['age']!.text,
                                'civilStatus': _controllers['civilStatus']!.text,
                                'gender': _controllers['gender']!.text,
                                'purok': _controllers['purok']!.text,
                                'voterStatus': _controllers['voterStatus']!.text,
                                'email': _controllers['email']!.text,
                                'contact': _controllers['contact']!.text,
                                'occupation': _controllers['occupation']!.text,
                                'citizenship': _controllers['citizenship']!.text,
                                'address': _controllers['address']!.text,
                                'householdNo': _controllers['householdNo']!.text,
                                'profileImage': imageUrl,
                                'createdAt': FieldValue.serverTimestamp(),
                              };
                              try {
                                await saveResidentToFirestore(residentData);
                                setState(() { _isUploading = false; });
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Success'),
                                    content: Text('Resident added successfully!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                setState(() { _isUploading = false; });
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Error'),
                                    content: Text('Failed to add resident. Please try again.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          child: _isUploading ? CircularProgressIndicator(color: Colors.white) : Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _residentTextField(String hint, {IconData? icon, TextEditingController? controller, bool required = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _residentDropdown(List<String> items, String hint, {TextEditingController? controller, bool required = true}) {
    return DropdownButtonFormField<String>(
      value: controller?.text.isNotEmpty == true ? controller!.text : null,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {
        if (controller != null) controller.text = value ?? '';
      },
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }
} 