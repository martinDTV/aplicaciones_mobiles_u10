import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Matemática',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalculadoraMatematica(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculadoraMatematica extends StatefulWidget {
  @override
  _CalculadoraMatematicaState createState() => _CalculadoraMatematicaState();
}

class _CalculadoraMatematicaState extends State<CalculadoraMatematica> {
  TextEditingController _numero1Controller = TextEditingController();
  TextEditingController _numero2Controller = TextEditingController();
  double _resultado = 0;
  String _operacionActual = 'suma';
  String _mensajeError = '';

  void _calcular() {
    setState(() {
      _mensajeError = '';
      double numero1 = double.tryParse(_numero1Controller.text) ?? 0;
      double numero2 = double.tryParse(_numero2Controller.text) ?? 0;

      switch (_operacionActual) {
        case 'suma':
          _resultado = numero1 + numero2;
          break;
        case 'resta':
          _resultado = numero1 - numero2;
          break;
        case 'multiplicacion':
          _resultado = numero1 * numero2;
          break;
        case 'division':
          if (numero2 == 0) {
            _mensajeError = 'Error: No se puede dividir por cero';
            _resultado = 0;
          } else {
            _resultado = numero1 / numero2;
          }
          break;
      }
    });
  }

  void _limpiar() {
    setState(() {
      _numero1Controller.clear();
      _numero2Controller.clear();
      _resultado = 0;
      _mensajeError = '';
    });
  }

  String _getOperationSymbol() {
    switch (_operacionActual) {
      case 'suma':
        return '+';
      case 'resta':
        return '-';
      case 'multiplicacion':
        return '×';
      case 'division':
        return '÷';
      default:
        return '+';
    }
  }

  String _getOperationName() {
    switch (_operacionActual) {
      case 'suma':
        return 'Suma';
      case 'resta':
        return 'Resta';
      case 'multiplicacion':
        return 'Multiplicación';
      case 'division':
        return 'División';
      default:
        return 'Suma';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora Matemática'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          
          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100,
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isWideScreen ? 32.0 : 16.0),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 600 : double.infinity,
                    ),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isWideScreen ? 32.0 : 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Título
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                '🧮 ${_getOperationName()}',
                                style: TextStyle(
                                  fontSize: isWideScreen ? 28 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 20),
                            
                            // Campos de entrada
                            _buildInputField('Primer número', _numero1Controller, isWideScreen),
                            SizedBox(height: 16),
                            
                            // Símbolo de operación
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _getOperationSymbol(),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 8),
                            _buildInputField('Segundo número', _numero2Controller, isWideScreen),
                            SizedBox(height: 24),
                            
                            // Botones de operaciones
                            Container(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildOperationButton('suma', '+ Suma', Colors.green, isWideScreen),
                                  _buildOperationButton('resta', '- Resta', Colors.orange, isWideScreen),
                                  _buildOperationButton('multiplicacion', '× Multiplicar', Colors.purple, isWideScreen),
                                  _buildOperationButton('division', '÷ Dividir', Colors.red, isWideScreen),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Botones de acción
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _calcular,
                                    icon: Icon(Icons.calculate),
                                    label: Text('Calcular'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _limpiar,
                                    icon: Icon(Icons.clear),
                                    label: Text('Limpiar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue.shade600,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Resultado
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _mensajeError.isNotEmpty 
                                    ? Colors.red.shade50 
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _mensajeError.isNotEmpty 
                                      ? Colors.red.shade200 
                                      : Colors.blue.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Resultado:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (_mensajeError.isNotEmpty)
                                    Text(
                                      _mensajeError,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  else
                                    Text(
                                      _resultado % 1 == 0 
                                          ? _resultado.toInt().toString()
                                          : _resultado.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: isWideScreen ? 32 : 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isWideScreen) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontSize: isWideScreen ? 18 : 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isWideScreen ? 16 : 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildOperationButton(String operation, String label, Color color, bool isWideScreen) {
    bool isSelected = _operacionActual == operation;
    
    return SizedBox(
      width: isWideScreen ? 140 : 120,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _operacionActual = operation;
            _mensajeError = '';
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.white,
          foregroundColor: isSelected ? Colors.white : color,
          side: BorderSide(color: color, width: 2),
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isWideScreen ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
