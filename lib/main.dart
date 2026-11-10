import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

// ---------------------------------------------------------------------------
// Lógica del IMC (funciones puras, fuera del widget para poder probarlas)
// ---------------------------------------------------------------------------

/// Calcula el IMC: peso (kg) ÷ estatura (m)².
/// La estatura llega en centímetros y se convierte a metros dividiendo entre 100.
/// El resultado se redondea a un decimal ANTES de clasificarlo.
double calcularImc(double pesoKg, double estaturaCm) {
  final estaturaM = estaturaCm / 100;
  final imc = pesoKg / (estaturaM * estaturaM);
  return double.parse(imc.toStringAsFixed(1));
}

/// Clasifica el IMC (ya redondeado) con los límites 18.5, 25 y 30.
String obtenerCategoria(double imc) {
  if (imc < 18.5) {
    return 'Bajo peso';
  } else if (imc < 25) {
    return 'Peso normal';
  } else if (imc < 30) {
    return 'Sobrepeso';
  } else {
    return 'Obesidad';
  }
}

/// Mensaje de recomendación según la categoría.
String obtenerRecomendacion(String categoria) {
  switch (categoria) {
    case 'Bajo peso':
      return 'Te recomendamos mejorar tu alimentación.';
    case 'Peso normal':
      return '¡Sigue así, vas muy bien!';
    case 'Sobrepeso':
      return 'Te conviene cuidar tu alimentación y actividad física.';
    default:
      return 'Es importante buscar orientación profesional.';
  }
}

/// Color del borde de la etiqueta según la categoría (reto opcional).
Color obtenerColor(String categoria) {
  switch (categoria) {
    case 'Bajo peso':
      return Colors.blue;
    case 'Peso normal':
      return Colors.green;
    case 'Sobrepeso':
      return Colors.orange;
    default:
      return Colors.red;
  }
}

// ---------------------------------------------------------------------------
// Interfaz
// ---------------------------------------------------------------------------

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const ImcPage(),
    );
  }
}

class ImcPage extends StatefulWidget {
  const ImcPage({super.key});

  @override
  State<ImcPage> createState() => _ImcPageState();
}

class _ImcPageState extends State<ImcPage> {
  // Un controlador por cada TextField
  final _nombreCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _estaturaCtrl = TextEditingController();

  // Texto que se muestra en la etiqueta de resultado
  String _resultado = '';
  // Color del borde de la etiqueta (cambia según la categoría)
  Color _colorResultado = Colors.grey;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _pesoCtrl.dispose();
    _estaturaCtrl.dispose();
    super.dispose();
  }

  /// Abre un AlertDialog reutilizable con un título y un mensaje.
  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Lee los datos, valida, calcula el IMC, clasifica y arma el mensaje.
  void _calcular() {
    final nombre = _nombreCtrl.text.trim();
    final peso = double.tryParse(_pesoCtrl.text.trim());
    final estatura = double.tryParse(_estaturaCtrl.text.trim());

    // Validación: ningún dato vacío y números mayores que cero
    if (nombre.isEmpty ||
        peso == null ||
        estatura == null ||
        peso <= 0 ||
        estatura <= 0) {
      _mostrarDialogo(
        'Datos incompletos',
        'Escribe tu nombre, tu peso (kg) y tu estatura (cm) con números válidos.',
      );
      return;
    }

    final imc = calcularImc(peso, estatura);
    final categoria = obtenerCategoria(imc);
    final mensaje =
        'Hola, $nombre.\n'
        'Tu IMC es ${imc.toStringAsFixed(1)}.\n'
        'Tu estatus actual es: ${categoria.toLowerCase()}.\n'
        '${obtenerRecomendacion(categoria)}';

    // Actualiza la etiqueta en pantalla
    setState(() {
      _resultado = mensaje;
      _colorResultado = obtenerColor(categoria);
    });

    // Muestra el mismo mensaje en el diálogo
    _mostrarDialogo('Resultado', mensaje);
  }

  /// Vacía los campos y la etiqueta de resultado.
  void _limpiar() {
    _nombreCtrl.clear();
    _pesoCtrl.clear();
    _estaturaCtrl.clear();
    setState(() {
      _resultado = '';
      _colorResultado = Colors.grey;
    });
  }

  /// Cierra la aplicación (funciona en Android).
  void _salir() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conociendo tu IMC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre completo: cada palabra inicia con mayúscula
            TextField(
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Peso: teclado decimal, un punto y hasta dos decimales
            TextField(
              controller: _pesoCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Estatura: teclado numérico, solo dígitos enteros
            TextField(
              controller: _estaturaCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Estatura (cm)',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Botones
            ElevatedButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate),
              label: const Text('Calcular IMC'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _limpiar,
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Limpiar datos'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _salir,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Salir'),
            ),
            const SizedBox(height: 24),

            // Etiqueta de resultado (mismo mensaje que el diálogo)
            Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(minHeight: 100),
              decoration: BoxDecoration(
                border: Border.all(color: _colorResultado, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _resultado.isEmpty ? 'Aquí aparecerá tu resultado.' : _resultado,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El IMC es una referencia general para personas adultas; '
              'no es un diagnóstico médico.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
