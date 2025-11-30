import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de Auto-Scan'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: const [
              Text(
                'Auto-Scan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Versión 1.0.0',
                style: TextStyle(color: Colors.black54),
              ),
              SizedBox(height: 20),

              Text(
                '¿Qué es Auto-Scan?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Auto-Scan es una aplicación que utiliza modelos de '
                'inteligencia artificial para clasificar vehículos a partir '
                'de una fotografía. Está pensada como una herramienta didáctica '
                'y de apoyo para proyectos de visión por computadora.',
              ),

             /* SizedBox(height: 20),
              Text(
                '¿Cómo funciona?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1. Tomas una foto del vehículo con la cámara integrada.\n'
                '2. La imagen se envía a un modelo de IA entrenado para '
                'reconocer el tipo de vehículo.\n'
                '3. La app te muestra la etiqueta predicha y el nivel de '
                'confianza del modelo.\n'
                '4. Opcionalmente puedes guardar el resultado en tu historial.',
              ),

              SizedBox(height: 20),
              Text(
                'Privacidad y datos',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Auto-Scan almacena información básica de tu cuenta (nombre '
                'y correo) y un registro de tus escaneos (etiqueta, confianza '
                'y fecha). Las imágenes pueden dejar de almacenarse según la '
                'configuración actual del historial.\n\n'
                'Los datos se guardan en Firebase (Authentication y Firestore) '
                'y se utilizan únicamente con fines académicos y de mejora del sistema.',
              ),

              SizedBox(height: 20),
              Text(
                'Créditos',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Desarrollo de la aplicación, integración de IA y diseño de la '
                'interfaz realizados por el equipo de Auto-Scan.\n\n'
                'Tecnologías utilizadas: Flutter, Firebase Auth, Cloud Firestore '
                'y modelos de TensorFlow/IA desplegados en la nube.',
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
