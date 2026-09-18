import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/user_service.dart';
import '../../state/auth_controller.dart';
import '../../widgets/app_logo.dart';

/// Pantalla de acceso: Google o correo y contrasena.
///
/// En la Fase 1 la autenticacion es simulada. Se usa la cuenta de prueba
/// definida en `AuthRepository`.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isRegistering = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final AuthController auth = context.read<AuthController>();
    if (_isRegistering) {
      await auth.register(
        fullName: _name.text,
        email: _email.text,
        password: _password.text,
      );
    } else {
      await auth.signInWithPassword(
        email: _email.text,
        password: _password.text,
      );
    }
  }

  void _useDemoAccount() {
    setState(() {
      _isRegistering = false;
      _email.text = AuthRepository.demoEmail;
      _password.text = AuthRepository.demoPassword;
    });
    context.read<AuthController>().clearError();
  }

  /// Diagnostico temporal (oculto): long-press en el titulo.
  /// Autentica con el formulario, lee users/{uid} y muestra el resultado.
  /// No pasa por AuthController ni altera el flujo normal de login.
  Future<void> _runUsersDocDiag() async {
    FocusScope.of(context).unfocus();
    final String email = _email.text.trim();
    final String password = _password.text;
    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Diag: completa correo y contrasena (>=6) antes de diagnosticar.',
          ),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String report;
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;
      final String uid = user?.uid ?? '(null)';

      DocumentSnapshot<Map<String, dynamic>>? snap;
      Object? readError;
      try {
        snap = await FirebaseFirestore.instance
            .collection(UserService.collectionName)
            .doc(uid)
            .get();
      } catch (e) {
        readError = e;
      }

      final bool exists = snap?.exists ?? false;
      final Map<String, dynamic>? data = snap?.data();
      final StringBuffer buf = StringBuffer()
        ..writeln('=== DIAG users/{uid} ===')
        ..writeln('FirebaseAuth.currentUser.uid: $uid')
        ..writeln('email: ${user?.email}')
        ..writeln('exists: $exists');
      if (readError != null) {
        buf
          ..writeln('GET ERROR: $readError')
          ..writeln('(tipo: ${readError.runtimeType})');
      }
      if (data != null) {
        buf.writeln('data completa:');
        for (final MapEntry<String, dynamic> e in data.entries) {
          buf.writeln('  ${e.key}: ${e.value}');
        }
      } else if (readError == null) {
        buf.writeln('data: null (documento ausente)');
      }

      report = buf.toString();

      // Restaurar sesion limpia: no dejar Auth abierta fuera de AuthController.
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    } catch (e) {
      report = '=== DIAG FAIL ===\n$e\n(tipo: ${e.runtimeType})';
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // loading

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Diag users/{uid}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: SelectableText(
              report,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: report));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diag copiado')),
                );
              }
            },
            child: const Text('Copiar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= 960;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: wide
          ? Row(
              children: <Widget>[
                const Expanded(flex: 8, child: _BrandPanel()),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: AppColors.ink,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 420),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: _form(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const _MobileHeader(),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B), // azul oscuro elegante
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: _form(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _form(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AuthController auth = context.watch<AuthController>();
    final bool busy = auth.isBusy;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onLongPress: _runUsersDocDiag,
            child: Text(
              _isRegistering ? 'Crea tu cuenta' : 'Inicia sesion',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          Text(
            'Accede a tu cuenta',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),         
          ),
          const SizedBox(height: 26),

          OutlinedButton.icon(
  onPressed: busy
      ? null
      : () => context.read<AuthController>().signInWithGoogle(),
  icon: const _GoogleMark(),
  label: const Text(
    'Continuar con Google',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),

          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
  'o con tu correo',
  style: theme.textTheme.bodySmall?.copyWith(
    color: Colors.white70,
  ),
),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 22),

          if (_isRegistering) ...<Widget>[
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                hintText: 'Felipe Soto',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (String? value) =>
                  (value == null || value.trim().length < 3)
                  ? 'Escribe tu nombre completo'
                  : null,
            ),
            const SizedBox(height: 14),
          ],

          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Correo electronico',
              hintText: 'nombre@taller.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (String? value) {
              final String email = (value ?? '').trim();
              if (email.isEmpty) return 'Ingresa tu correo';
              final bool valid = RegExp(
                r'^[\w.\-+]+@[\w\-]+\.[\w\-.]+$',
              ).hasMatch(email);
              return valid ? null : 'El correo no tiene un formato valido';
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _password,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.password],
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Contrasena',
              hintText: 'Minimo 6 caracteres',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ),
            validator: (String? value) => (value ?? '').length < 6
                ? 'La contrasena debe tener al menos 6 caracteres'
                : null,
          ),

          if (!_isRegistering)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy
                    ? null
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La recuperacion de contrasena llega con el backend',
                          ),
                        ),
                      ),
                child: const Text('Olvide mi contrasena'),
              ),
            ),

          if (auth.errorMessage != null) ...<Widget>[
            const SizedBox(height: 6),
            _ErrorBanner(message: auth.errorMessage!),
          ],

          const SizedBox(height: 18),
          FilledButton(
            onPressed: busy ? null : _submit,
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(_isRegistering ? 'Crear cuenta' : 'Ingresar'),
          ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _isRegistering ? 'Ya tienes cuenta?' : 'Eres nuevo?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate,
                ),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                        context.read<AuthController>().clearError();
                        setState(() => _isRegistering = !_isRegistering);
                      },
                child: Text(_isRegistering ? 'Inicia sesion' : 'Crea tu cuenta'),
              ),
            ],
          ),

          /*
          if (!_isRegistering) ...<Widget>[
            const SizedBox(height: 8),
            _DemoCard(onUse: busy ? null : _useDemoAccount),
          ],
          */
        ],
      ),
    );
  }
}

/// Panel izquierdo de marca que se ve en pantallas anchas.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    const List<(IconData, String, String)> highlights =
        <(IconData, String, String)>[
          /*(
            Icons.inventory_2_rounded,
            'Catalogo verificado',
            'Referencias con SKU y numero OEM para no equivocarte.',
          ),
          (
            Icons.search_rounded,
            'Busqueda rapida',
            'Encuentra por nombre, marca, SKU u OEM en segundos.',
          ),
          (
            Icons.verified_user_rounded,
            'Marcas homologadas',
            'Bosch, Brembo, Monroe, NGK, Gates y mas, con garantia.',
          ),*/
        ];


    return Container(
      decoration: const BoxDecoration(),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
  child: Transform.scale(
    scale: 1.0,
    child: Image.asset(
      'assets/images/login_bg1.png',
      fit: BoxFit.contain,
      alignment: const Alignment(0.2, 0.5),
    ),
  ),
),

          /*Positioned.fill(
            right: -80,
            top: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brand.withValues(alpha: 0.12),
              ),
            ),
          ),*/
          Positioned(
            right: -60,
            bottom: -40,
            child: Icon(
              Icons.settings_rounded,
              size: 260,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                
                const SizedBox(height: 20),
                const Text(
                  '\n',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 14),
                /*Text(
                  'Catalogo profesional de repuestos automotrices para talleres '
                  'y almacenes.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),*/
                const SizedBox(height: 44),
                for (final (IconData icon, String title, String body)
                    in highlights)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.brand,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                body,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13.5,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

/// Cabecera de marca para moviles.
class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.51,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // Imagen
          Image.asset(
            'assets/images/login_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          
          /*
          // Oscurece ligeramente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),
          */

          // Texto encima
          const Positioned(
            left: 24,
            right: 24,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '\n',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta con las credenciales de la cuenta de demostracion.
class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.onUse});

  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.key_rounded, color: AppColors.brand, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Cuenta de prueba', style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${AuthRepository.demoEmail} · ${AuthRepository.demoPassword}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onUse, child: const Text('Usar')),
        ],
      ),
    );
  }
}

/// Logotipo simplificado de Google para el boton de acceso.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        'assets/icons/Google.png',
      ),
    );
  }
}