import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/location/browser_geolocation_stub.dart'
    if (dart.library.html) '../../core/location/browser_geolocation_web.dart'
    as browser_geo;
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../models/workshop_data.dart';
import '../../services/workshop_service.dart';
import '../../state/auth_controller.dart';
import '../../widgets/common.dart';

/// Formulario de datos del taller/empresa → `users/{uid}.workshop`.
class WorkshopProfileScreen extends StatefulWidget {
  const WorkshopProfileScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const WorkshopProfileScreen()),
    );
  }

  @override
  State<WorkshopProfileScreen> createState() => _WorkshopProfileScreenState();
}

class _WorkshopProfileScreenState extends State<WorkshopProfileScreen> {
  final WorkshopService _service = const WorkshopService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _razonSocialCtrl;
  late final TextEditingController _nombreComercialCtrl;
  late final TextEditingController _rucCtrl;
  late final TextEditingController _propietarioCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _referenciaCtrl;
  late final TextEditingController _departamentoCtrl;
  late final TextEditingController _provinciaCtrl;
  late final TextEditingController _distritoCtrl;

  bool _loading = true;
  bool _saving = false;
  bool _locating = false;
  String? _loadError;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    final String email =
        context.read<AuthController>().user?.email.trim() ?? '';
    final String fullName =
        context.read<AuthController>().user?.fullName.trim() ?? '';

    _razonSocialCtrl = TextEditingController();
    _nombreComercialCtrl = TextEditingController();
    _rucCtrl = TextEditingController();
    _propietarioCtrl = TextEditingController(text: fullName);
    _telefonoCtrl = TextEditingController();
    _whatsappCtrl = TextEditingController();
    _correoCtrl = TextEditingController(text: email);
    _direccionCtrl = TextEditingController();
    _referenciaCtrl = TextEditingController();
    _departamentoCtrl = TextEditingController();
    _provinciaCtrl = TextEditingController();
    _distritoCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _razonSocialCtrl.dispose();
    _nombreComercialCtrl.dispose();
    _rucCtrl.dispose();
    _propietarioCtrl.dispose();
    _telefonoCtrl.dispose();
    _whatsappCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _referenciaCtrl.dispose();
    _departamentoCtrl.dispose();
    _provinciaCtrl.dispose();
    _distritoCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final WorkshopData? data = await _service.getWorkshop();
      if (!mounted) return;
      if (data != null) {
        _apply(data);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'No se pudieron cargar los datos del taller.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _apply(WorkshopData data) {
    _razonSocialCtrl.text = data.razonSocial;
    _nombreComercialCtrl.text = data.nombreComercial;
    _rucCtrl.text = data.ruc;
    if (data.propietario.isNotEmpty) {
      _propietarioCtrl.text = data.propietario;
    }
    _telefonoCtrl.text = data.telefono;
    _whatsappCtrl.text = data.whatsapp;
    if (data.correo.isNotEmpty) {
      _correoCtrl.text = data.correo;
    }
    _direccionCtrl.text = data.direccion;
    _referenciaCtrl.text = data.referencia;
    _departamentoCtrl.text = data.departamento;
    _provinciaCtrl.text = data.provincia;
    _distritoCtrl.text = data.distrito;
    _lat = data.lat;
    _lng = data.lng;
  }

  WorkshopData _fromForm() {
    return WorkshopData(
      razonSocial: _razonSocialCtrl.text,
      nombreComercial: _nombreComercialCtrl.text,
      ruc: _rucCtrl.text,
      propietario: _propietarioCtrl.text,
      telefono: _telefonoCtrl.text,
      whatsapp: _whatsappCtrl.text,
      correo: _correoCtrl.text,
      direccion: _direccionCtrl.text,
      referencia: _referenciaCtrl.text,
      departamento: _departamentoCtrl.text,
      provincia: _provinciaCtrl.text,
      distrito: _distritoCtrl.text,
      lat: _lat,
      lng: _lng,
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      await _service.saveWorkshop(_fromForm());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron guardar los datos: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      if (!kIsWeb) {
        final bool serviceEnabled =
            await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _snack('Activa el servicio de ubicacion del dispositivo.');
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied) {
          _snack('Se necesita permiso de ubicacion.');
          return;
        }
        if (permission == LocationPermission.deniedForever) {
          _snack(
            'El permiso de ubicacion esta bloqueado. '
            'Habilitalo en la configuracion del navegador o del sistema.',
          );
          return;
        }
      }

      debugPrint(
        'GEO INSTANCE: ${GeolocatorPlatform.instance.runtimeType}',
      );

      late final double latitude;
      late final double longitude;

      try {
        final Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (e) {
        if (!kIsWeb) rethrow;
        debugPrint('Geolocator web fallo, usando dart:html: $e');
        final ({double latitude, double longitude}) browser =
            await browser_geo.getBrowserCurrentPosition();
        latitude = browser.latitude;
        longitude = browser.longitude;
      }

      debugPrint('LAT=$latitude LNG=$longitude');

      if (!mounted) return;
      setState(() {
        _lat = latitude;
        _lng = longitude;
      });
      _snack('Ubicación obtenida correctamente.');
    } catch (e, s) {
      final String msg = e.toString().toLowerCase();
      final bool permissionDenied = e is PermissionDeniedException ||
          msg.contains('denied') ||
          msg.contains('permission');

      if (kIsWeb && permissionDenied) {
        _snack('Se necesita permiso de ubicación del navegador.');
      } else {
        _snack(
          'No se pudo obtener la ubicación: $e',
        );
      }
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label es obligatorio';
    }
    return null;
  }

  String? _email(String? value) {
    final String? required = _required(value, 'Correo');
    if (required != null) return required;
    final String email = value!.trim();
    final bool ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) return 'Correo no valido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = context.horizontalPadding;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Datos del Taller')),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 820,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
              ? EmptyState(
                  icon: Icons.store_mall_directory_outlined,
                  title: 'Sin datos',
                  message: _loadError!,
                  actionLabel: 'Reintentar',
                  onAction: _load,
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 28),
                    children: <Widget>[
                      _SectionCard(
                        title: 'Informacion General',
                        children: <Widget>[
                          _field(
                            controller: _razonSocialCtrl,
                            label: 'Razon Social *',
                            textInputAction: TextInputAction.next,
                            validator: (String? v) =>
                                _required(v, 'Razon Social'),
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _nombreComercialCtrl,
                            label: 'Nombre Comercial',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _rucCtrl,
                            label: 'RUC *',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (String? v) => _required(v, 'RUC'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Contacto',
                        children: <Widget>[
                          _field(
                            controller: _propietarioCtrl,
                            label: 'Propietario *',
                            textInputAction: TextInputAction.next,
                            validator: (String? v) =>
                                _required(v, 'Propietario'),
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _telefonoCtrl,
                            label: 'Telefono *',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: (String? v) =>
                                _required(v, 'Telefono'),
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _whatsappCtrl,
                            label: 'WhatsApp',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _correoCtrl,
                            label: 'Correo *',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _email,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Ubicacion',
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: _locating ? null : _useCurrentLocation,
                            icon: _locating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                            label: Text(
                              _locating
                                  ? 'Obteniendo ubicacion...'
                                  : 'Usar mi ubicacion actual',
                            ),
                          ),
                          if (_lat != null && _lng != null) ...<Widget>[
                            const SizedBox(height: 8),
                            Text(
                              'Coords: ${_lat!.toStringAsFixed(6)}, '
                              '${_lng!.toStringAsFixed(6)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 14),
                          _field(
                            controller: _departamentoCtrl,
                            label: 'Departamento',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _provinciaCtrl,
                            label: 'Provincia',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _distritoCtrl,
                            label: 'Distrito',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _direccionCtrl,
                            label: 'Direccion',
                            textInputAction: TextInputAction.next,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _referenciaCtrl,
                            label: 'Referencia',
                            textInputAction: TextInputAction.done,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          _saving ? 'Guardando...' : 'Guardar Datos',
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
