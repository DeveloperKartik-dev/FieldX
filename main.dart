import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'api_service.dart';

void main() {

  runApp(const LandSurveyApp());

}

class LandSurveyApp extends StatelessWidget {
  const LandSurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Land Survey',

      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14532D)),

        scaffoldBackgroundColor: Color.fromARGB(255, 247, 248, 245),
 
        useMaterial3: true,

      ),

      home: const LoginPage(),

    );

  }

}



class LoginPage extends StatefulWidget {

  const LoginPage({super.key});



  @override

  State<LoginPage> createState() => _LoginPageState();

}



class _LoginPageState extends State<LoginPage>

    with SingleTickerProviderStateMixin {

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();



  late AnimationController _animationController;

  late Animation<Offset> _logoAnimation;

  late Animation<double> _formAnimation;



  @override

  void initState() {

    super.initState();



    _animationController = AnimationController(

      vsync: this,

      duration: const Duration(milliseconds: 800),

    );



    _logoAnimation =

        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(

          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),

        );



    _formAnimation = CurvedAnimation(

      parent: _animationController,

      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),

    );



    _animationController.forward();

  }



  Widget usernameField() {

    return SizedBox(

      width: 300,

      child: TextField(

        controller: usernameController,

        decoration: InputDecoration(

          labelText: 'Officer ID',

          labelStyle: const TextStyle(fontWeight: FontWeight.bold),

          contentPadding: const EdgeInsets.symmetric(

            horizontal: 16,

            vertical: 15,

          ),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

          prefixIcon: const Icon(Icons.person),

        ),

      ),

    );

  }



  Widget passwordField() {

  return SizedBox(

    width: 300,

    child: TextField(

      controller: passwordController,

      obscureText: true,

      decoration: InputDecoration(

        labelText: 'Password',

        labelStyle: const TextStyle(fontWeight: FontWeight.bold),

        contentPadding: const EdgeInsets.symmetric(

          horizontal: 16,

          vertical: 15,

        ),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

        ),

        prefixIcon: const Icon(Icons.lock),

      ),

    ),

  );

}



  Widget loginButton() {
    return SizedBox(
      width: 300,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 12,
          shadowColor: Colors.black54,
          backgroundColor: const Color(0xFF14532D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: () async {
          final officerId = usernameController.text.trim();
          final password = passwordController.text;

          if (officerId.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter Officer ID and Password'),
              ),
            );
            return;
          }

          try {
            final data = await ApiService.login(
              officerId: officerId,
              password: password,
            );

            final user = data['user'];
            if (user is Map<String, dynamic> && user['user_id'] != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('user_id', (user['user_id'] as num).toInt());
              await prefs.setString('officer_id', officerId);
              await prefs.setString(
                'full_name',
                user['full_name']?.toString() ?? '',
              );
            }

            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        },
        child: const Text(
          'LOGIN',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }



  Widget forgotPasswordButton() {

    return Align(

      alignment: Alignment.center,

      child: TextButton(

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),

          );

        },

        child: const Text(

          'Forgot Password?',

          style: TextStyle(

            color: Color(0xFF14532D),

            fontWeight: FontWeight.w600,

          ),

        ),

      ),

    );

  }



  Widget signupButton() {

    return Row(

      mainAxisAlignment: MainAxisAlignment.center,

      children: [

        const Text("Don't have an account?  "),

        TextButton(

          style: TextButton.styleFrom(

            padding: EdgeInsets.zero,

            minimumSize: Size.zero,

            tapTargetSize: MaterialTapTargetSize.shrinkWrap,

          ),

          onPressed: () {

            Navigator.push(

              context,

              MaterialPageRoute(builder: (_) => const SignUpPage()),

            );

          },

          child: const Text(

            'Sign Up',

            style: TextStyle(

              color: Color(0xFF14532D),

              fontWeight: FontWeight.bold,

            ),

          ),

        ),

      ],

    );

  }



 @override

void dispose() {

  usernameController.dispose();

  passwordController.dispose();

  _animationController.dispose();

  super.dispose();

}



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

          Positioned(

            top: -80,

            right: -80,

            child: Container(

              width: 220,

              height: 220,

              decoration: BoxDecoration(

                color: const Color(0xFF14532D).withValues(alpha: 0.04),

                shape: BoxShape.circle,

              ),

            ),

          ),

          Positioned(

            bottom: -100,

            left: -100,

            child: Container(

              width: 250,

              height: 250,

              decoration: BoxDecoration(

                color: const Color(0xFF14532D).withValues(alpha: 0.04),

                shape: BoxShape.circle,

              ),

            ),

          ),

          Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                SlideTransition(

                  position: _logoAnimation,

                  child: Column(

                    children: [

                      ClipRRect(

                        borderRadius: BorderRadius.circular(20),

                        child: Image.asset(

                          'assets/fieldx_logo.png',

                          height: 80,

                          width: 80,

                          fit: BoxFit.cover,

                        ),

                      ),

                      const SizedBox(height: 9),

                      const Text(

                        'FieldX',

                        style: TextStyle(

                          fontSize: 28,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                    ],

                  ),

                ),

                const SizedBox(height: 10),

                FadeTransition(

                  opacity: _formAnimation,

                  child: Container(

                    width: 340,

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [

                        BoxShadow(

                          color: Colors.black.withValues(alpha: 0.06),

                          blurRadius: 20,

                          offset: const Offset(0, 8),

                        ),

                      ],

                    ),

                    child: Column(

                      children: [

                        const SizedBox(height: 20),

                        usernameField(),

                        const SizedBox(height: 15),

                        passwordField(),

                        const SizedBox(height: 20),

                        loginButton(),

                        const SizedBox(height: 2),

                        forgotPasswordButton(),

                        const SizedBox(height: 0),

                        signupButton(),

                      ],

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



class SignUpPage extends StatefulWidget {

  const SignUpPage({super.key});



  @override

  State<SignUpPage> createState() => _SignUpPageState();

}



class _SignUpPageState extends State<SignUpPage> {

  final nameController = TextEditingController();

  final usernameController = TextEditingController();

  final mobileController = TextEditingController();

  final otpController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();



  int currentStep = 0;

  String generatedOtp = '';

  bool showPassword = false;

  bool showConfirmPassword = false;



  @override

  void dispose() {

    nameController.dispose();

    usernameController.dispose();

    mobileController.dispose();

    otpController.dispose();

    passwordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();

  }



  InputDecoration fieldDecoration({

    required String label,

    required IconData icon,

    String? hint,

  }) {

    return InputDecoration(

      labelText: label,

      hintText: hint,

      prefixIcon: Icon(icon, color: const Color(0xFF14532D)),

      filled: true,

      fillColor: const Color(0xFFF8FAF9),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      border: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFFD9E2DC)),

      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFFD9E2DC)),

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFF14532D), width: 1.5),

      ),

    );

  }



  void goToOtpPage() {

    if (nameController.text.trim().isEmpty) {

      showMessage('Please enter your full name');

      return;

    }



    if (usernameController.text.trim().isEmpty) {

      showMessage('Please enter a Officer ID');

      return;

    }



    if (mobileController.text.trim().length != 10) {

      showMessage('Please enter a valid 10-digit mobile number');

      return;

    }



    generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)

        .toString();



    setState(() {

      currentStep = 1;

    });

  }



  Future<void> createAccount() async {
    if (otpController.text.trim() != generatedOtp) {
      showMessage('Invalid OTP');
      return;
    }

    final fullName = nameController.text.trim();
    final officerId = usernameController.text.trim();
    final mobileNo = mobileController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (fullName.isEmpty) {
      showMessage('Please enter your full name');
      return;
    }

    if (officerId.length != 8 || !RegExp(r'^[0-9]+$').hasMatch(officerId)) {
      showMessage('Officer ID must be exactly 8 digits');
      return;
    }

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobileNo)) {
      showMessage('Please enter a valid 10-digit mobile number');
      return;
    }

    if (password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      showMessage(
        'Password must contain 8+ characters, uppercase, lowercase, number and special character',
      );
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match');
      return;
    }

    try {
      final data = await ApiService.signup(
        fullName: fullName,
        officerId: officerId,
        mobileNo: mobileNo,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;
      showMessage(data['message']?.toString() ?? 'Account created successfully');

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString());
    }
  }



  void showMessage(String message) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),

    );

  }



  Widget buildLogo() {

    return ClipRRect(

      borderRadius: BorderRadius.circular(18),

      child: Image.asset(

        'assets/fieldx_logo.png',

        height: 72,

        width: 72,

        fit: BoxFit.cover,

      ),

    );

  }



  Widget buildProgress() {

    return Row(

      children: [

        Expanded(

          child: Container(

            height: 5,

            decoration: BoxDecoration(

              color: const Color(0xFF14532D),

              borderRadius: BorderRadius.circular(10),

            ),

          ),

        ),

        const SizedBox(width: 8),

        Expanded(

          child: Container(

            height: 5,

            decoration: BoxDecoration(

              color: currentStep == 1

                  ? const Color(0xFF14532D)

                  : const Color(0xFFD9E2DC),

              borderRadius: BorderRadius.circular(10),

            ),

          ),

        ),

      ],

    );

  }



  Widget buildStepOne() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        TextField(

          controller: nameController,

          textCapitalization: TextCapitalization.words,

          decoration: fieldDecoration(

            label: 'Full Name',

            icon: Icons.person_outline,

            hint: 'Enter your full name',

          ),

        ),

        const SizedBox(height: 16),

        TextField(

          controller: usernameController,

          decoration: fieldDecoration(

            label: 'Officer ID',

            icon: Icons.account_circle_outlined,

            hint: 'Enter Your Officer ID',

          ),

        ),

        const SizedBox(height: 16),

        TextField(

          controller: mobileController,

          keyboardType: TextInputType.phone,

          maxLength: 10,

          decoration: fieldDecoration(

            label: 'Mobile Number',

            icon: Icons.phone_outlined,

            hint: '10-digit mobile number',

          ).copyWith(counterText: ''),

        ),

        const SizedBox(height: 24),

        SizedBox(

          width: double.infinity,

          height: 52,

          child: ElevatedButton(

            onPressed: goToOtpPage,

            style: ElevatedButton.styleFrom(

              backgroundColor: const Color(0xFF14532D),

              foregroundColor: Colors.white,

              elevation: 3,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

            ),

            child: const Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Text(

                  'CONTINUE',

                  style: TextStyle(

                    fontSize: 15,

                    fontWeight: FontWeight.bold,

                    letterSpacing: 0.5,

                  ),

                ),

                SizedBox(width: 8),

                Icon(Icons.arrow_forward, size: 20),

              ],

            ),

          ),

        ),

      ],

    );

  }



  Widget buildStepTwo() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(

          children: [

            Expanded(

              child: TextField(

                controller: otpController,

                keyboardType: TextInputType.number,

                maxLength: 6,

                decoration: fieldDecoration(

                  label: 'Enter OTP',

                  icon: Icons.verified_user_outlined,

                ).copyWith(counterText: ''),

              ),

            ),

            const SizedBox(width: 10),

            Container(

              height: 56,

              padding: const EdgeInsets.symmetric(horizontal: 12),

              decoration: BoxDecoration(

                color: const Color(0xFFEAF4ED),

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: const Color(0xFFB8D5C1)),

              ),

              alignment: Alignment.center,

              child: Text(

                generatedOtp,

                style: const TextStyle(

                  color: Color(0xFF14532D),

                  fontWeight: FontWeight.bold,

                  letterSpacing: 1.5,

                ),

              ),

            ),

          ],

        ),

        const SizedBox(height: 8),

        const Text(

          'Demo OTP',

          style: TextStyle(fontSize: 12, color: Colors.grey),

        ),

        const SizedBox(height: 18),

        TextField(

          controller: passwordController,

          obscureText: !showPassword,

          decoration:

              fieldDecoration(

                label: 'Password',

                icon: Icons.lock_outline,

              ).copyWith(

                suffixIcon: IconButton(

                  onPressed: () {

                    setState(() {

                      showPassword = !showPassword;

                    });

                  },

                  icon: Icon(

                    showPassword

                        ? Icons.visibility_off_outlined

                        : Icons.visibility_outlined,

                  ),

                ),

              ),

        ),

        const SizedBox(height: 16),

        TextField(

          controller: confirmPasswordController,

          obscureText: !showConfirmPassword,

          decoration:

              fieldDecoration(

                label: 'Confirm Password',

                icon: Icons.lock_reset_outlined,

              ).copyWith(

                suffixIcon: IconButton(

                  onPressed: () {

                    setState(() {

                      showConfirmPassword = !showConfirmPassword;

                    });

                  },

                  icon: Icon(

                    showConfirmPassword

                        ? Icons.visibility_off_outlined

                        : Icons.visibility_outlined,

                  ),

                ),

              ),

        ),

        const SizedBox(height: 24),

        SizedBox(

          width: double.infinity,

          height: 52,

          child: ElevatedButton(

            onPressed: createAccount,

            style: ElevatedButton.styleFrom(

              backgroundColor: const Color(0xFF14532D),

              foregroundColor: Colors.white,

              elevation: 3,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

            ),

            child: const Text(

              'CREATE ACCOUNT',

              style: TextStyle(

                fontSize: 15,

                fontWeight: FontWeight.bold,

                letterSpacing: 0.5,

              ),

            ),

          ),

        ),

      ],

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F8F6),

      appBar: AppBar(

        backgroundColor: const Color(0xFF14532D),

        foregroundColor: Colors.white,

        centerTitle: false,

        title: const Text(

          'Create Account',

          style: TextStyle(fontWeight: FontWeight.bold),

        ),

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),

        child: Center(

          child: Container(

            width: 340,

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(20),

              boxShadow: [

                BoxShadow(

                  color: Colors.black.withValues(alpha: 0.06),

                  blurRadius: 20,

                  offset: const Offset(0, 8),

                ),

              ],

            ),

            child: Column(

              children: [

                buildLogo(),

                const SizedBox(height: 12),

                const Text(

                  'Create your FieldX account',

                  style: TextStyle(

                    fontSize: 20,

                    fontWeight: FontWeight.bold,

                    color: Color(0xFF17221B),

                  ),

                  textAlign: TextAlign.center,

                ),

                const SizedBox(height: 6),

                Text(

                  currentStep == 0

                      ? 'Enter your details to continue'

                      : 'Verify your mobile number and secure your account',

                  style: const TextStyle(fontSize: 13, color: Colors.grey),

                  textAlign: TextAlign.center,

                ),

                const SizedBox(height: 20),

                buildProgress(),

                const SizedBox(height: 22),

                AnimatedSwitcher(

                  duration: const Duration(milliseconds: 250),

                  child: currentStep == 0 ? buildStepOne() : buildStepTwo(),

                ),

                if (currentStep == 1) ...[

                  const SizedBox(height: 14),

                  TextButton.icon(

                    onPressed: () {

                      setState(() {

                        currentStep = 0;

                      });

                    },

                    icon: const Icon(Icons.arrow_back, size: 18),

                    label: const Text('Back to basic details'),

                    style: TextButton.styleFrom(

                      foregroundColor: const Color(0xFF14532D),

                    ),

                  ),

                ],

              ],

            ),

          ),

        ),

      ),

    );

  }

}



class HomePage extends StatefulWidget {

  const HomePage({super.key});



  @override

  State<HomePage> createState() => _HomePageState();

}



class _HomePageState extends State<HomePage> {

  List<Map<String, dynamic>> parcels = [];



  @override

  void initState() {

    super.initState();

    loadParcels();

  }



  Future<void> loadParcels() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('parcels');

    if (data != null) {
      try {
        parcels = List<Map<String, dynamic>>.from(jsonDecode(data));
      } catch (_) {
        parcels = [];
      }
    }

    if (mounted) setState(() {});
    await syncPendingParcels();
  }



  Future<void> saveParcel(Map<String, dynamic> parcel) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    final localParcel = Map<String, dynamic>.from(parcel);
    localParcel['sync_pending'] = true;
    localParcel['sync_error'] = '';

    if (userId == null) {
      localParcel['sync_error'] = 'Login session not found';
      parcels.add(localParcel);
      await prefs.setString('parcels', jsonEncode(parcels));
      if (mounted) setState(() {});
      return;
    }

    try {
      final area = double.parse(localParcel['area'].toString());
      final latitude = (localParcel['latitude'] as num).toDouble();
      final longitude = (localParcel['longitude'] as num).toDouble();
      final address =
          'GPS ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

      final parcelResponse = await ApiService.createLandParcel(
        surveyNumber: localParcel['khasra'].toString(),
        ownerName: localParcel['owner'].toString(),
        area: area,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      final serverParcel = parcelResponse['parcel'];
      final parcelId = serverParcel is Map<String, dynamic>
          ? (serverParcel['parcel_id'] as num).toInt()
          : null;

      if (parcelId == null) {
        throw ApiException('Server did not return parcel ID.');
      }

      await ApiService.createSurvey(
        parcelId: parcelId,
        userId: userId,
      );

      localParcel['parcel_id'] = parcelId;
      localParcel['user_id'] = userId;
      localParcel['sync_pending'] = false;
      localParcel['sync_error'] = '';
    } catch (e) {
      localParcel['sync_pending'] = true;
      localParcel['sync_error'] = e.toString();
    }

    parcels.add(localParcel);
    await prefs.setString('parcels', jsonEncode(parcels));

    if (mounted) setState(() {});
  }



  Future<void> syncPendingParcels() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;

    bool changed = false;

    for (final parcel in parcels) {
      if (parcel['sync_pending'] != true) continue;

      try {
        final area = double.parse(parcel['area'].toString());
        final latitude = (parcel['latitude'] as num).toDouble();
        final longitude = (parcel['longitude'] as num).toDouble();
        final address =
            'GPS ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

        final response = await ApiService.createLandParcel(
          surveyNumber: parcel['khasra'].toString(),
          ownerName: parcel['owner'].toString(),
          area: area,
          latitude: latitude,
          longitude: longitude,
          address: address,
        );

        final serverParcel = response['parcel'];
        final parcelId = serverParcel is Map<String, dynamic>
            ? (serverParcel['parcel_id'] as num).toInt()
            : null;

        if (parcelId == null) throw ApiException('Server did not return parcel ID.');

        await ApiService.createSurvey(parcelId: parcelId, userId: userId);
        parcel['parcel_id'] = parcelId;
        parcel['user_id'] = userId;
        parcel['sync_pending'] = false;
        parcel['sync_error'] = '';
        changed = true;
      } catch (e) {
        parcel['sync_error'] = e.toString();
      }
    }

    if (changed) {
      await prefs.setString('parcels', jsonEncode(parcels));
      if (mounted) setState(() {});
    }
  }



  void openSurveyForm() {

    Navigator.push(

      context,

      MaterialPageRoute(builder: (_) => SurveyForm(onSave: saveParcel)),

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: const Color(0xFF14532D),

        foregroundColor: Colors.white,

        titleSpacing: 16,

        title: Row(

          children: [

            Image.asset('assets/fieldx_logo.png', height: 34, width: 34),

            const SizedBox(width: 10),

            const Text(

              'FieldX',

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),

            ),

          ],

        ),

      ),



      body: parcels.isEmpty

          ? const Center(

              child: Text(

                'No parcels surveyed yet',

                style: TextStyle(fontSize: 18),

              ),

            )

          : ListView.builder(

              padding: const EdgeInsets.all(12),

              itemCount: parcels.length,

              itemBuilder: (context, index) {

                final parcel = parcels[index];



                return Card(

                  child: ListTile(

                    leading: const CircleAvatar(child: Icon(Icons.landscape)),

                    title: Text(

                      'Khasra: ${parcel['khasra']}',

                      style: const TextStyle(fontWeight: FontWeight.bold),

                    ),

                    subtitle: Text(

                      'Owner: ${parcel['owner']}\n'

                      'Area: ${parcel['area']}\n'

                      'Latitude: ${parcel['latitude']}\n'

                      'Longitude: ${parcel['longitude']}',

                    ),

                    isThreeLine: true,

                  ),

                );

              },

            ),



      floatingActionButton: FloatingActionButton.extended(

        onPressed: openSurveyForm,

        backgroundColor: const Color(0xFF14532D),

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add_location_alt),

        label: const Text('New Survey'),

      ),

    );

  }

}



class SurveyForm extends StatefulWidget {

  final Function(Map<String, dynamic>) onSave;



  const SurveyForm({super.key, required this.onSave});



  @override

  State<SurveyForm> createState() => _SurveyFormState();

}



class _SurveyFormState extends State<SurveyForm> {

  final khasraController = TextEditingController();

  final ownerController = TextEditingController();

  final areaController = TextEditingController();



  Position? currentPosition;

  File? landPhoto;



  bool gettingLocation = false;



  Future<void> getLocation() async {

    setState(() {

      gettingLocation = true;

    });



    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();



      if (!serviceEnabled) {

        setState(() {

          gettingLocation = false;

        });



        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text(

                'Please enable GPS/location services on your device.',

              ),

            ),

          );

        }



        return;

      }



      LocationPermission permission = await Geolocator.checkPermission();



      if (permission == LocationPermission.denied) {

        permission = await Geolocator.requestPermission();

      }



      if (permission == LocationPermission.deniedForever) {

        setState(() {

          gettingLocation = false;

        });



        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(

              content: const Text(

                'Location permission is permanently denied. '

                'Please enable it from app settings.',

              ),

              action: SnackBarAction(

                label: 'SETTINGS',

                onPressed: () {

                  Geolocator.openAppSettings();

                },

              ),

            ),

          );

        }



        return;

      }



      if (permission == LocationPermission.denied) {

        setState(() {

          gettingLocation = false;

        });



        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text(

                'Location permission is required for land surveying.',

              ),

            ),

          );

        }



        return;

      }



      final position = await Geolocator.getCurrentPosition(

        locationSettings: const LocationSettings(

          accuracy: LocationAccuracy.high,

        ),

      );



      setState(() {

        currentPosition = position;

        gettingLocation = false;

      });



      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(content: Text('GPS location captured successfully.')),

        );

      }

    } catch (e) {

      setState(() {

        gettingLocation = false;

      });



      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('Unable to capture location: $e')),

        );

      }

    }

  }



  Future<void> takePhoto() async {

    final picker = ImagePicker();



    final image = await picker.pickImage(

      source: ImageSource.camera,

      imageQuality: 80,

    );



    if (image != null) {

      setState(() {

        landPhoto = File(image.path);

      });

    }

  }



  Future<void> saveSurvey() async {

    if (khasraController.text.trim().isEmpty ||

        ownerController.text.trim().isEmpty ||

        areaController.text.trim().isEmpty ||

        currentPosition == null) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text('Please fill all details and capture GPS location.'),

        ),

      );



      return;

    }



    final parcel = {

      'khasra': khasraController.text.trim(),

      'owner': ownerController.text.trim(),

      'area': areaController.text.trim(),

      'latitude': currentPosition!.latitude,

      'longitude': currentPosition!.longitude,

      'accuracy': currentPosition!.accuracy,

      'photo': landPhoto?.path ?? '',

      'date': DateTime.now().toIso8601String(),

    };



    await widget.onSave(parcel);



    if (mounted) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Land survey saved successfully.')),

      );



      Navigator.pop(context);

    }

  }



  @override

  void dispose() {

    khasraController.dispose();

    ownerController.dispose();

    areaController.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Land Survey')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            TextField(

              controller: khasraController,

              decoration: const InputDecoration(

                labelText: 'Khasra / Survey Number',

                border: OutlineInputBorder(),

                prefixIcon: Icon(Icons.numbers),

              ),

            ),



            const SizedBox(height: 15),



            TextField(

              controller: ownerController,

              decoration: const InputDecoration(

                labelText: 'Owner Name',

                border: OutlineInputBorder(),

                prefixIcon: Icon(Icons.person),

              ),

            ),



            const SizedBox(height: 15),



            TextField(

              controller: areaController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: 'Land Area',

                hintText: 'Example: 2.5 acre',

                border: OutlineInputBorder(),

                prefixIcon: Icon(Icons.square_foot),

              ),

            ),



            const SizedBox(height: 20),



            ElevatedButton.icon(

              onPressed: gettingLocation ? null : getLocation,

              icon: const Icon(Icons.gps_fixed),

              label: Text(

                gettingLocation

                    ? 'Getting Location...'

                    : currentPosition == null

                    ? 'Capture GPS Location'

                    : 'GPS Location Captured',

              ),

            ),



            if (currentPosition != null) ...[

              const SizedBox(height: 15),



              Card(

                child: Padding(

                  padding: const EdgeInsets.all(15),

                  child: Column(

                    children: [

                      const Row(

                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          Icon(Icons.location_on, color: Colors.green),

                          SizedBox(width: 8),

                          Text(

                            'GPS Location',

                            style: TextStyle(

                              fontSize: 17,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                        ],

                      ),



                      const SizedBox(height: 12),



                      Text(

                        'Latitude\n'

                        '${currentPosition!.latitude}',

                        textAlign: TextAlign.center,

                      ),



                      const SizedBox(height: 8),



                      Text(

                        'Longitude\n'

                        '${currentPosition!.longitude}',

                        textAlign: TextAlign.center,

                      ),



                      const SizedBox(height: 8),



                      Text(

                        'Accuracy: '

                        '${currentPosition!.accuracy.toStringAsFixed(2)} metres',

                        textAlign: TextAlign.center,

                      ),

                    ],

                  ),

                ),

              ),

            ],



            const SizedBox(height: 20),



            ElevatedButton.icon(

              onPressed: takePhoto,

              icon: const Icon(Icons.camera_alt),

              label: const Text('Capture Land Photo'),

            ),



            if (landPhoto != null) ...[

              const SizedBox(height: 15),



              ClipRRect(

                borderRadius: BorderRadius.circular(12),

                child: Image.file(landPhoto!, height: 220, fit: BoxFit.cover),

              ),

            ],



            const SizedBox(height: 30),



            FilledButton.icon(

              onPressed: saveSurvey,

              icon: const Icon(Icons.save),

              label: const Padding(

                padding: EdgeInsets.all(14),

                child: Text(

                  'SAVE SURVEY',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}



class ForgotPasswordPage extends StatefulWidget {

  const ForgotPasswordPage({super.key});



  @override

  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();

}



class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final mobileController = TextEditingController();

  final otpController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();



  int currentStep = 0;

  String generatedOtp = '';



  bool showPassword = false;

  bool showConfirmPassword = false;



  @override

  void dispose() {

    mobileController.dispose();

    otpController.dispose();

    passwordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();

  }



  InputDecoration fieldDecoration({

    required String label,

    required IconData icon,

    String? hint,

  }) {

    return InputDecoration(

      labelText: label,

      hintText: hint,

      prefixIcon: Icon(icon, color: const Color(0xFF14532D)),

      filled: true,

      fillColor: const Color(0xFFF8FAF9),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      border: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFFD9E2DC)),

      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFFD9E2DC)),

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFF14532D), width: 1.5),

      ),

    );

  }



  void showMessage(String message) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),

    );

  }



  void sendOtp() {

    if (mobileController.text.trim().length != 10) {

      showMessage('Please enter a valid 10-digit mobile number');

      return;

    }



    generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)

        .toString();



    setState(() {

      currentStep = 1;

    });

  }



  void resetPassword() {

    if (otpController.text.trim() != generatedOtp) {

      showMessage('Invalid OTP');

      return;

    }



    if (passwordController.text.length < 6) {

      showMessage('Password must be at least 6 characters');

      return;

    }



    if (passwordController.text != confirmPasswordController.text) {

      showMessage('Passwords do not match');

      return;

    }



    showMessage('Password reset successfully');



    Future.delayed(const Duration(milliseconds: 700), () {

      if (mounted) {

        Navigator.pop(context);

      }

    });

  }



  Widget buildLogo() {

    return ClipRRect(

      borderRadius: BorderRadius.circular(18),

      child: Image.asset(

        'assets/fieldx_logo.png',

        height: 72,

        width: 72,

        fit: BoxFit.cover,

      ),

    );

  }



  Widget buildProgress() {

    return Row(

      children: [

        Expanded(

          child: Container(

            height: 5,

            decoration: BoxDecoration(

              color: const Color(0xFF14532D),

              borderRadius: BorderRadius.circular(10),

            ),

          ),

        ),

        const SizedBox(width: 8),

        Expanded(

          child: Container(

            height: 5,

            decoration: BoxDecoration(

              color: currentStep == 1

                  ? const Color(0xFF14532D)

                  : const Color(0xFFD9E2DC),

              borderRadius: BorderRadius.circular(10),

            ),

          ),

        ),

      ],

    );

  }



  Widget buildStepOne() {

    return Column(

      children: [

        TextField(

          controller: mobileController,

          keyboardType: TextInputType.phone,

          maxLength: 10,

          decoration: fieldDecoration(

            label: 'Mobile Number',

            icon: Icons.phone_outlined,

            hint: 'Enter registered mobile number',

          ).copyWith(counterText: ''),

        ),

        const SizedBox(height: 24),

        SizedBox(

          width: double.infinity,

          height: 52,

          child: ElevatedButton(

            onPressed: sendOtp,

            style: ElevatedButton.styleFrom(

              backgroundColor: const Color(0xFF14532D),

              foregroundColor: Colors.white,

              elevation: 3,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

            ),

            child: const Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Text(

                  'SEND OTP',

                  style: TextStyle(

                    fontSize: 15,

                    fontWeight: FontWeight.bold,

                    letterSpacing: 0.5,

                  ),

                ),

                SizedBox(width: 8),

                Icon(Icons.arrow_forward, size: 20),

              ],

            ),

          ),

        ),

      ],

    );

  }



  Widget buildStepTwo() {

    return Column(

      children: [

        Row(

          children: [

            Expanded(

              child: TextField(

                controller: otpController,

                keyboardType: TextInputType.number,

                maxLength: 6,

                decoration: fieldDecoration(

                  label: 'Enter OTP',

                  icon: Icons.verified_user_outlined,

                ).copyWith(counterText: ''),

              ),

            ),

            const SizedBox(width: 10),

            Container(

              height: 56,

              padding: const EdgeInsets.symmetric(horizontal: 12),

              decoration: BoxDecoration(

                color: const Color(0xFFEAF4ED),

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: const Color(0xFFB8D5C1)),

              ),

              alignment: Alignment.center,

              child: Text(

                generatedOtp,

                style: const TextStyle(

                  color: Color(0xFF14532D),

                  fontWeight: FontWeight.bold,

                  letterSpacing: 1.5,

                ),

              ),

            ),

          ],

        ),

        const SizedBox(height: 6),

        const Align(

          alignment: Alignment.centerLeft,

          child: Text(

            'Demo OTP',

            style: TextStyle(fontSize: 12, color: Colors.grey),

          ),

        ),

        const SizedBox(height: 18),

        TextField(

          controller: passwordController,

          obscureText: !showPassword,

          decoration:

              fieldDecoration(

                label: 'New Password',

                icon: Icons.lock_outline,

              ).copyWith(

                suffixIcon: IconButton(

                  onPressed: () {

                    setState(() {

                      showPassword = !showPassword;

                    });

                  },

                  icon: Icon(

                    showPassword

                        ? Icons.visibility_off_outlined

                        : Icons.visibility_outlined,

                  ),

                ),

              ),

        ),

        const SizedBox(height: 16),

        TextField(

          controller: confirmPasswordController,

          obscureText: !showConfirmPassword,

          decoration:

              fieldDecoration(

                label: 'Confirm Password',

                icon: Icons.lock_reset_outlined,

              ).copyWith(

                suffixIcon: IconButton(

                  onPressed: () {

                    setState(() {

                      showConfirmPassword = !showConfirmPassword;

                    });

                  },

                  icon: Icon(

                    showConfirmPassword

                        ? Icons.visibility_off_outlined

                        : Icons.visibility_outlined,

                  ),

                ),

              ),

        ),

        const SizedBox(height: 24),

        SizedBox(

          width: double.infinity,

          height: 52,

          child: ElevatedButton(

            onPressed: resetPassword,

            style: ElevatedButton.styleFrom(

              backgroundColor: const Color(0xFF14532D),

              foregroundColor: Colors.white,

              elevation: 3,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

            ),

            child: const Text(

              'RESET PASSWORD',

              style: TextStyle(

                fontSize: 15,

                fontWeight: FontWeight.bold,

                letterSpacing: 0.5,

              ),

            ),

          ),

        ),

      ],

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F8F6),

      appBar: AppBar(

        backgroundColor: const Color(0xFF14532D),

        foregroundColor: Colors.white,

        centerTitle: false,

        title: const Text(

          'Reset Password',

          style: TextStyle(fontWeight: FontWeight.bold),

        ),

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),

        child: Center(

          child: Container(

            width: 340,

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(20),

              boxShadow: [

                BoxShadow(

                  color: Colors.black.withValues(alpha: 0.06),

                  blurRadius: 20,

                  offset: const Offset(0, 8),

                ),

              ],

            ),

            child: Column(

              children: [

                buildLogo(),

                const SizedBox(height: 12),

                const Text(

                  'Reset your password',

                  style: TextStyle(

                    fontSize: 20,

                    fontWeight: FontWeight.bold,

                    color: Color(0xFF17221B),

                  ),

                  textAlign: TextAlign.center,

                ),

                const SizedBox(height: 6),

                Text(

                  currentStep == 0

                      ? 'Verify your registered mobile number'

                      : 'Enter the OTP and create a new password',

                  style: const TextStyle(fontSize: 13, color: Colors.grey),

                  textAlign: TextAlign.center,

                ),

                const SizedBox(height: 20),

                buildProgress(),

                const SizedBox(height: 22),

                AnimatedSwitcher(

                  duration: const Duration(milliseconds: 250),

                  child: currentStep == 0 ? buildStepOne() : buildStepTwo(),

                ),

                if (currentStep == 1) ...[

                  const SizedBox(height: 14),

                  TextButton.icon(

                    onPressed: () {

                      setState(() {

                        currentStep = 0;

                      });

                    },

                    icon: const Icon(Icons.arrow_back, size: 18),

                    label: const Text('Change mobile number'),

                    style: TextButton.styleFrom(

                      foregroundColor: const Color(0xFF14532D),

                    ),

                  ),

                ],

              ],

            ),

          ),

        ),

      ),

    );

  }

}
