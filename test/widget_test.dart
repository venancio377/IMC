import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:imc/main.dart';

void main() {
  // Casos 1 a 7 de la tabla de la práctica
  group('Cálculo y clasificación del IMC', () {
    final casos = [
      (45.0, 160.0, 17.6, 'Bajo peso'),
      (70.0, 175.0, 22.9, 'Peso normal'),
      (75.0, 165.0, 27.5, 'Sobrepeso'),
      (100.0, 170.0, 34.6, 'Obesidad'),
      (60.0, 180.0, 18.5, 'Peso normal'),
      (73.0, 170.0, 25.3, 'Sobrepeso'),
      (87.0, 170.0, 30.1, 'Obesidad'),
    ];

    for (final (peso, estatura, imcEsperado, categoriaEsperada) in casos) {
      test('$peso kg · $estatura cm → $imcEsperado ($categoriaEsperada)', () {
        final imc = calcularImc(peso, estatura);
        expect(imc, imcEsperado);
        expect(obtenerCategoria(imc), categoriaEsperada);
      });
    }

    test('Se redondea antes de clasificar (24.96 → 25.0 → Sobrepeso)', () {
      expect(obtenerCategoria(double.parse(24.96.toStringAsFixed(1))),
          'Sobrepeso');
    });
  });

  testWidgets('Muestra el resultado en diálogo y etiqueta', (tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('Conociendo tu IMC'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Luis');
    await tester.enterText(find.byType(TextField).at(1), '70');
    await tester.enterText(find.byType(TextField).at(2), '175');
    await tester.tap(find.text('Calcular IMC'));
    await tester.pumpAndSettle();

    // El mensaje aparece dos veces: en el diálogo y en la etiqueta
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Tu IMC es 22.9'), findsNWidgets(2));

    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('peso normal'), findsOneWidget);

    // Caso 9: Limpiar datos
    await tester.tap(find.text('Limpiar datos'));
    await tester.pump();
    expect(find.textContaining('Tu IMC es'), findsNothing);
    expect(find.text('Luis'), findsNothing);
  });

  testWidgets('Caso 8: datos incompletos muestra diálogo', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.enterText(find.byType(TextField).at(0), 'Ana');
    await tester.tap(find.text('Calcular IMC'));
    await tester.pumpAndSettle();
    expect(find.text('Datos incompletos'), findsOneWidget);
  });
}
