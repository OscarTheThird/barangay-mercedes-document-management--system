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
  String? _editingIdNumber;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _controllers['birthday']?.addListener(_updateAgeFromBirthday);
  }

  void _updateAgeFromBirthday() {
    final text = _controllers['birthday']?.text ?? '';
    final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    final match = regex.firstMatch(text);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      final year = int.tryParse(match.group(3)!);
      if (day != null && month != null && year != null) {
        final birthDate = DateTime(year, month, day);
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        _controllers['age']?.text = age.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Current user: \\${FirebaseAuth.instance.currentUser}');
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1500),
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
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: residentsStream(),
                  builder: (context, snapshot) {
                    print('StreamBuilder called, connectionState: \\${snapshot.connectionState}');
                    if (snapshot.hasError) {
                      print('StreamBuilder error: \\${snapshot.error}');
                      return Center(child: Text('Error: \\${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No residents found.'));
                    }
                    final filteredResidents = snapshot.data!;
                    // Filter by ID number or any part of the name
                    final filteredResidentsFiltered = filteredResidents.where((data) {
                      final idMatch = (data['idNumber'] ?? '').toString().toLowerCase().contains(_search.toLowerCase());
                      final nameMatch = (data['firstname'] ?? '').toString().toLowerCase().contains(_search.toLowerCase()) ||
                        (data['middlename'] ?? '').toString().toLowerCase().contains(_search.toLowerCase()) ||
                        (data['lastname'] ?? '').toString().toLowerCase().contains(_search.toLowerCase());
                      return _search.isEmpty || idMatch || nameMatch;
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
                                DataColumn(
                                  label: Center(child: Text('')),
                                ),
                                DataColumn(
                                  label: Center(child: Text('ID Number', style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                                DataColumn(
                                  label: Container(
                                    width: 220,
                                    alignment: Alignment.center,
                                    child: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  ),
                                ),
                                DataColumn(
                                  label: Center(child: Text('House No.', style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                                DataColumn(
                                  label: Center(child: Text('Purok', style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                                DataColumn(
                                  label: Center(child: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                                DataColumn(
                                  label: Center(child: Text('Civil Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                                DataColumn(
                                  label: Center(child: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                                DataColumn(
                                  label: Center(child: Text('Voter Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                                DataColumn(
                                  label: Container(
                                    width: 120,
                                    alignment: Alignment.center,
                                    child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  ),
                                ),
                              ],
                              rows: List.generate(filteredResidentsFiltered.take(_rowsPerPage).length, (i) {
                                final data = filteredResidentsFiltered[i];
                                final isEven = i % 2 == 0;
                                return DataRow(
                                  color: MaterialStateProperty.all(isEven ? Color(0xFFF8F8FA) : Colors.white),
                                  cells: [
                                    DataCell(Center(child: data['profileImage'] != null && data['profileImage'] != ''
                                        ? CircleAvatar(backgroundImage: NetworkImage(data['profileImage']), radius: 20)
                                        : CircleAvatar(child: Icon(Icons.person), radius: 20))),
                                    DataCell(Center(child: Text(data['idNumber'] ?? ''))),
                                    DataCell(
                                      Container(
                                        width: 220,
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
                                    DataCell(Center(child: Text(data['householdNo'] ?? ''))),
                                    DataCell(Center(child: Text(data['purok'] ?? ''))),
                                    DataCell(Center(child: Text(data['age']?.toString() ?? ''))),
                                    DataCell(Center(child: Text(data['civilStatus'] ?? ''))),
                                    DataCell(Center(child: Text(data['gender'] ?? ''))),
                                    DataCell(Center(child: Text(data['voterStatus'] ?? ''))),
                                    DataCell(
                                      Container(
                                        width: 120,
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.green),
                                              tooltip: 'Edit',
                                              onPressed: () {
                                                _showResidentForm(resident: data, viewOnly: false);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.visibility, color: Colors.blue),
                                              tooltip: 'View',
                                              onPressed: () {
                                                _showResidentForm(resident: data, viewOnly: true);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              tooltip: 'Delete',
                                              onPressed: () {
                                                _deleteResident(data);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                            Text('Showing 1 to \\${filteredResidentsFiltered.length < _rowsPerPage ? filteredResidentsFiltered.length : _rowsPerPage} of \\${filteredResidentsFiltered.length} entries'),
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

  Future<String> generateResidentId(String purok) async {
    // Parse purok and sub-purok
    final purokReg = RegExp(r'^Purok (\d{1,2})(?:\s*-\s*([AB]))?');
    final match = purokReg.firstMatch(purok);
    String purokNum = '00';
    String subPurok = '0';
    if (match != null) {
      purokNum = match.group(1)!.padLeft(2, '0');
      final sub = match.group(2);
      if (sub == 'A') subPurok = '1';
      else if (sub == 'B') subPurok = '2';
    }
    // Count existing residents in this purok/sub-purok subcollection
    final query = await FirebaseFirestore.instance
      .collection('residents')
      .doc(purok)
      .collection('list')
      .get();
    int count = query.docs.length + 1;
    String sequence = count.toString().padLeft(4, '0');
    return '$purokNum$subPurok$sequence';
  }

  Future<void> saveResidentToFirestore(String purok, Map<String, dynamic> residentData) async {
    await FirebaseFirestore.instance
      .collection('residents')
      .doc(purok)
      .collection('list')
      .add(residentData);
  }

  void _showResidentForm({Map<String, dynamic>? resident, bool viewOnly = false}) async {
    // Pre-fill controllers with resident data if editing or viewing
    if (resident != null) {
      _controllers['firstname']?.text = resident['firstname'] ?? '';
      _controllers['middlename']?.text = resident['middlename'] ?? '';
      _controllers['lastname']?.text = resident['lastname'] ?? '';
      _controllers['suffix']?.text = resident['suffix'] ?? '';
      _controllers['birthplace']?.text = resident['birthplace'] ?? '';
      _controllers['birthday']?.text = resident['birthday'] ?? '';
      _controllers['age']?.text = resident['age']?.toString() ?? '';
      _controllers['civilStatus']?.text = resident['civilStatus'] ?? '';
      _controllers['gender']?.text = resident['gender'] ?? '';
      _controllers['purok']?.text = resident['purok'] ?? '';
      _controllers['voterStatus']?.text = resident['voterStatus'] ?? '';
      _controllers['email']?.text = resident['email'] ?? '';
      _controllers['contact']?.text = resident['contact'] ?? '';
      _controllers['occupation']?.text = resident['occupation'] ?? '';
      _controllers['citizenship']?.text = resident['citizenship'] ?? '';
      _controllers['address']?.text = resident['address'] ?? '';
      _controllers['householdNo']?.text = resident['householdNo'] ?? '';
      _editingIdNumber = resident['idNumber'] ?? '';
      _profileImageUrl = resident['profileImage'] ?? '';
    } else {
      _editingIdNumber = null;
      _profileImageUrl = null;
    }
    String? previewIdNumber;
    final ValueNotifier<String?> idPreviewNotifier = ValueNotifier<String?>(null);
    void updateIdPreview() async {
      final purok = _controllers['purok']!.text;
      if (purok.isNotEmpty) {
        final id = await generateResidentId(purok);
        idPreviewNotifier.value = id;
      } else {
        idPreviewNotifier.value = null;
      }
    }
    _controllers['purok']!.addListener(updateIdPreview);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
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
                                      resident == null
                                          ? 'Add Resident'
                                          : (viewOnly ? 'Resident Information' : 'Edit Resident'),
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
                                                    ? (_selectedImageBytes != null
                                                        ? MemoryImage(_selectedImageBytes!)
                                                        : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                                            ? NetworkImage(_profileImageUrl!)
                                                            : null))
                                                    : (_selectedImage != null
                                                        ? FileImage(_selectedImage!)
                                                        : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                                            ? NetworkImage(_profileImageUrl!)
                                                            : null)),
                                                  child: (_selectedImage == null && _selectedImageBytes == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                                                    ? Icon(Icons.person, size: 80, color: Colors.grey)
                                                    : null,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 18),
                                            if (!viewOnly)
                                              OutlinedButton.icon(
                                                onPressed: () async {
                                                  var img = await pickImage();
                                                  setState(() {
                                                    if (kIsWeb) {
                                                      _selectedImageBytes = img;
                                                      _selectedImage = null;
                                                    } else {
                                                      _selectedImage = img;
                                                      _selectedImageBytes = null;
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
                                            // ID Number preview (always read-only)
                                            SizedBox(height: 12),
                                            ValueListenableBuilder<String?>(
                                              valueListenable: idPreviewNotifier,
                                              builder: (context, value, _) {
                                                final controller = TextEditingController(text: value ?? _editingIdNumber ?? '');
                                                return TextFormField(
                                                  controller: controller,
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    labelText: 'ID Number',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                );
                                              },
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
                                            _residentTextField('Enter Household No.', controller: _controllers['householdNo'], readOnly: viewOnly),
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
                                                Expanded(child: _residentTextField('Enter Firstname', controller: _controllers['firstname'], readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Expanded(child: _residentTextField('Enter Middlename', controller: _controllers['middlename'], readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Expanded(child: _residentTextField('Enter Lastname', controller: _controllers['lastname'], readOnly: viewOnly)),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Flexible(flex: 4, child: _residentTextField('Enter Suffix (Optional)', controller: _controllers['suffix'], required: false, readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Flexible(flex: 5, child: _residentTextField('Enter Birthplace', controller: _controllers['birthplace'], readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Flexible(flex: 5, child: _residentTextField(
                                                  'dd/mm/yyyy',
                                                  icon: Icons.calendar_today,
                                                  controller: _controllers['birthday'],
                                                  onIconTap: () async {
                                                    DateTime initialDate = DateTime.now().subtract(Duration(days: 365 * 18));
                                                    final text = _controllers['birthday']?.text ?? '';
                                                    final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
                                                    final match = regex.firstMatch(text);
                                                    if (match != null) {
                                                      final day = int.tryParse(match.group(1)!);
                                                      final month = int.tryParse(match.group(2)!);
                                                      final year = int.tryParse(match.group(3)!);
                                                      if (day != null && month != null && year != null) {
                                                        initialDate = DateTime(year, month, day);
                                                      }
                                                    }
                                                    DateTime? picked = await showDatePicker(
                                                      context: context,
                                                      initialDate: initialDate,
                                                      firstDate: DateTime(1900),
                                                      lastDate: DateTime.now(),
                                                      initialDatePickerMode: DatePickerMode.year,
                                                    );
                                                    if (picked != null) {
                                                      String formatted = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                                      _controllers['birthday']!.text = formatted;
                                                    }
                                                  },
                                                  readOnly: viewOnly,
                                                )),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(child: _residentTextField('Enter Age', controller: _controllers['age'], readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Expanded(child: _residentDropdown(['Single', 'Married', 'Widowed', 'Separated'], 'Select Civil Status', controller: _controllers['civilStatus'], readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Expanded(child: _residentDropdown(['Male', 'Female'], 'Select Gender', controller: _controllers['gender'], readOnly: viewOnly)),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(child: _residentDropdown([
                                                  'Purok 1',
                                                  'Purok 2',
                                                  'Purok 3',
                                                  'Purok 4',
                                                  'Purok 4 - A',
                                                  'Purok 4 - B',
                                                  'Purok 5',
                                                  'Purok 6',
                                                  'Purok 7',
                                                  'Purok 8',
                                                  'Purok 9',
                                                  'Purok 10',
                                                  'Purok 11',
                                                  'Purok 12',
                                                  'Purok 13',
                                                ], 'Select Purok', controller: _controllers['purok'], readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Expanded(child: _residentDropdown(['Voter', 'Non-Voter'], 'Select Voters Status', controller: _controllers['voterStatus'], readOnly: viewOnly)),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(child: _residentTextField('Enter Email', controller: _controllers['email'], readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Expanded(child: _residentTextField('Enter Contact Number', controller: _controllers['contact'], readOnly: viewOnly)),
                                                SizedBox(width: 8),
                                                Expanded(child: _residentTextField('Enter Occupation', controller: _controllers['occupation'], readOnly: viewOnly)),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(child: _residentTextField('Enter Citizenship', controller: _controllers['citizenship'], readOnly: viewOnly)),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            _residentTextField('Enter Address', controller: _controllers['address'], readOnly: viewOnly),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (viewOnly)
                        Padding(
                          padding: EdgeInsets.only(right: 32, bottom: 24, top: 16),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Close'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.only(right: 32, bottom: 24, top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _isUploading ? null : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() { _isUploading = true; });
                                    String? imageUrl = _profileImageUrl;
                                    try {
                                      if (_selectedImage != null || _selectedImageBytes != null) {
                                        imageUrl = await uploadImageToCloudinary(kIsWeb ? _selectedImageBytes : _selectedImage);
                                      }
                                      String purok = _controllers['purok']!.text;
                                      Map<String, dynamic> residentData = {
                                        'idNumber': resident == null
                                            ? idPreviewNotifier.value ?? ''
                                            : _editingIdNumber ?? '',
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
                                      if (resident != null && resident['docId'] != null) {
                                        // Editing: update the existing document
                                        await FirebaseFirestore.instance
                                          .collection('residents')
                                          .doc(purok)
                                          .collection('list')
                                          .doc(resident['docId'])
                                          .update(residentData);
                                      } else {
                                        // Adding: create a new document
                                        await FirebaseFirestore.instance
                                          .collection('residents')
                                          .doc(purok)
                                          .collection('list')
                                          .add(residentData);
                                      }
                                      setState(() { _isUploading = false; });
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Success'),
                                          content: Text(resident != null ? 'Resident updated successfully!' : 'Resident added successfully!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } catch (e, st) {
                                      print('Error saving resident: $e\n$st');
                                      setState(() { _isUploading = false; });
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Error'),
                                          content: Text('Failed to save resident. Please try again.'),
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
                                child: _isUploading
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text(resident == null ? 'Add' : 'Save Changes'),
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
      },
    );
    // Clean up listeners after dialog closes
    _controllers['purok']!.removeListener(updateIdPreview);
    _controllers.forEach((key, controller) => controller.clear());
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
      _editingIdNumber = null;
      _profileImageUrl = null;
    });
  }

  Widget _residentTextField(String hint, {IconData? icon, TextEditingController? controller, bool required = true, VoidCallback? onIconTap, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: hint.replaceFirst('Enter ', '').replaceFirst(' (Optional)', ''),
        hintText: hint,
        prefixIcon: icon != null
            ? GestureDetector(
                onTap: onIconTap,
                child: Icon(icon),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      validator: required && !readOnly
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _residentDropdown(List<String> items, String hint, {TextEditingController? controller, bool required = true, bool readOnly = false}) {
    return DropdownButtonFormField<String>(
      value: controller?.text.isNotEmpty == true ? controller!.text : null,
      decoration: InputDecoration(
        labelText: hint,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {
        if (controller != null) controller.text = value ?? '';
      },
      validator: required && !readOnly
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Stream<List<Map<String, dynamic>>> residentsStream() {
    // Stream for new structure: all /residents/{purok}/list/{docId}
    final listStream = FirebaseFirestore.instance.collectionGroup('list').snapshots();
    // Stream for old structure: all /residents/{docId} with firstname/lastname
    final rootStream = FirebaseFirestore.instance.collection('residents').snapshots();

    return listStream.asyncMap((listSnap) async {
      final allResidents = <Map<String, dynamic>>[];

      // Add new structure residents
      for (final doc in listSnap.docs) {
        final data = doc.data();
        final parentPath = doc.reference.parent.parent;
        data['purok'] = parentPath?.id ?? '';
        data['docId'] = doc.id; // Store Firestore docId for editing
        allResidents.add(data);
      }

      // Add old structure residents (from the latest root snapshot)
      final rootSnap = await rootStream.first;
      for (final doc in rootSnap.docs) {
        final data = doc.data();
        if (data.containsKey('firstname') && data.containsKey('lastname')) {
          data['purok'] = data['purok'] ?? 'Unknown';
          allResidents.add(data);
        }
      }

      return allResidents;
    });
  }

  void _deleteResident(Map<String, dynamic> resident) async {
    final purok = resident['purok'];
    final docId = resident['docId'];
    if (purok == null || docId == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Cannot delete this resident. Record is missing required information.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this resident? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance
        .collection('residents')
        .doc(purok)
        .collection('list')
        .doc(docId)
        .delete();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Deleted'),
          content: Text('Resident deleted successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to delete resident. Please try again.'),
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

  @override
  void dispose() {
    _controllers['birthday']?.removeListener(_updateAgeFromBirthday);
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
} 