import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/onboarding_api.dart';
import 'credentials_sent_page.dart';

/// Resident requests their NexBell credentials by building + apartment, to be
/// emailed to a personal address. Mirrors the doorman claim flow.
class RequestCredentialsPage extends StatefulWidget {
  const RequestCredentialsPage({super.key});

  @override
  State<RequestCredentialsPage> createState() => _RequestCredentialsPageState();
}

class _RequestCredentialsPageState extends State<RequestCredentialsPage> {
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _buildingFocus = FocusNode();

  List<BuildingOption> _buildings = [];
  List<BuildingOption> _suggestions = [];
  BuildingOption? _selectedBuilding;

  List<ApartmentOption> _apartments = [];
  String? _selectedApartment;

  bool _loadingBuildings = true;
  bool _loadingApartments = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _emailController.dispose();
    _buildingFocus.dispose();
    super.dispose();
  }

  Future<void> _loadBuildings() async {
    setState(() {
      _loadingBuildings = true;
      _error = null;
    });
    try {
      final buildings = await OnboardingApi.fetchBuildings();
      setState(() => _buildings = buildings);
    } catch (e) {
      setState(() => _error = 'No se pudieron cargar los edificios. Revisa tu conexión.');
    } finally {
      if (mounted) setState(() => _loadingBuildings = false);
    }
  }

  void _onBuildingChanged(String text) {
    final query = text.trim().toLowerCase();
    setState(() {
      // Typing again invalidates the previous selection.
      _selectedBuilding = null;
      _apartments = [];
      _selectedApartment = null;
      _suggestions = query.isEmpty
          ? []
          : _buildings
              .where((b) => b.name.toLowerCase().contains(query))
              .take(6)
              .toList();
    });
  }

  Future<void> _selectBuilding(BuildingOption building) async {
    _buildingFocus.unfocus();
    setState(() {
      _selectedBuilding = building;
      _buildingController.text = building.name;
      _suggestions = [];
      _loadingApartments = true;
      _apartments = [];
      _selectedApartment = null;
    });
    try {
      final apartments = await OnboardingApi.fetchApartments(building.id);
      // Only pending apartments can be claimed.
      setState(() => _apartments =
          apartments.where((a) => a.claimable).toList());
    } catch (_) {
      setState(() => _error = 'No se pudieron cargar los departamentos.');
    } finally {
      if (mounted) setState(() => _loadingApartments = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (_selectedBuilding == null) {
      setState(() => _error = 'Elige tu edificio de la lista.');
      return;
    }
    if (_selectedApartment == null) {
      setState(() => _error = 'Selecciona tu número de departamento.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Escribe un correo electrónico válido.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await OnboardingApi.claimResident(
        buildingName: _selectedBuilding!.name,
        apartmentCode: _selectedApartment!,
        personalEmail: email,
      );
      if (!mounted) return;
      if (result.sent) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CredentialsSentPage(
              destinationEmail: email,
              buildingName: _selectedBuilding!.name,
              apartmentCode: _selectedApartment!,
            ),
          ),
        );
      } else {
        setState(() => _error = result.message);
      }
    } catch (e) {
      setState(() => _error = 'No se pudo procesar la solicitud. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => _buildingFocus.unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 170,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/solicita_credencial.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Subtle bottom scrim so the status pill stays readable.
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.45),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 14,
                        child: _statusPill(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'SOLICITAR CREDENCIALES',
                  style: TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Si tu edificio ya cuenta con NexBell, solicita\ntus credenciales para empezar.',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                _label('SELECCIONA TU EDIFICIO'),
                const SizedBox(height: 8),
                _buildingField(),
                _suggestionList(),

                const SizedBox(height: 24),
                _label('NÚMERO DE DEPARTAMENTO'),
                const SizedBox(height: 8),
                _apartmentField(),

                const SizedBox(height: 24),
                _label('CORREO ELECTRÓNICO'),
                const SizedBox(height: 8),
                _emailField(),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFE57373), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFE57373),
                            fontSize: 13,
                            fontFamily: AppFonts.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.neutral,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.neutral,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Solicitar Credenciales',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.body,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        children: [
                          TextSpan(text: '¿Ya tienes tus credenciales? '),
                          TextSpan(
                            text: 'Iniciar Sesión',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, color: Color(0xFF6BD38A), size: 8),
          SizedBox(width: 8),
          Text(
            'SISTEMA ACTIVO',
            style: TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 11,
              letterSpacing: 1.5,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.label,
          letterSpacing: 0.5,
        ),
      );

  Widget _buildingField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: _selectedBuilding != null
            ? Border.all(color: AppColors.primary.withOpacity(0.5))
            : null,
      ),
      child: TextField(
        controller: _buildingController,
        focusNode: _buildingFocus,
        onChanged: _onBuildingChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: _loadingBuildings ? 'Cargando edificios...' : 'Elegir edificio...',
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: const Icon(Icons.apartment, color: Colors.grey, size: 20),
          suffixIcon: _loadingBuildings
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (_selectedBuilding != null
                  ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                  : const Icon(Icons.keyboard_arrow_down, color: Colors.grey)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        ),
      ),
    );
  }

  Widget _suggestionList() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: _suggestions.map((b) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.location_city, color: AppColors.primary, size: 20),
            title: Text(b.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: b.district.isEmpty
                ? null
                : Text(b.district, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            onTap: () => _selectBuilding(b),
          );
        }).toList(),
      ),
    );
  }

  Widget _apartmentField() {
    final enabled = _selectedBuilding != null && !_loadingApartments;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.meeting_room_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: _loadingApartments
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text('Cargando departamentos...',
                        style: TextStyle(color: Colors.white24)),
                  )
                : (_selectedBuilding == null
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('Primero elige tu edificio',
                            style: TextStyle(color: Colors.white24)),
                      )
                    : (_apartments.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text('No hay departamentos pendientes',
                                style: TextStyle(color: Colors.white24)),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedApartment,
                              dropdownColor: AppColors.surface,
                              hint: const Text('Selecciona departamento',
                                  style: TextStyle(color: Colors.white24)),
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              items: _apartments
                                  .map((a) => DropdownMenuItem(
                                        value: a.code,
                                        child: Text('Depto. ${a.code}'),
                                      ))
                                  .toList(),
                              onChanged: enabled
                                  ? (v) => setState(() => _selectedApartment = v)
                                  : null,
                            ),
                          ))),
          ),
        ],
      ),
    );
  }

  Widget _emailField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'tucorreo@ejemplo.com',
          hintStyle: TextStyle(color: Colors.white24),
          prefixIcon: Icon(Icons.alternate_email, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        ),
      ),
    );
  }
}
