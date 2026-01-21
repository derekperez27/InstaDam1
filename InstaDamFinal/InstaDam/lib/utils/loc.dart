import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

String tr(BuildContext context, String key, [Map<String, String>? args]) {
  AppProvider prov;
  try {
    prov = Provider.of<AppProvider>(context);
  } catch (_) {
    // In some contexts (event handlers) listening is not allowed. Fall back to
    // a non-listening lookup so tr() can be used from callbacks.
    prov = Provider.of<AppProvider>(context, listen: false);
  }
  final lang = prov.language;

  const Map<String, Map<String, String>> _t = {
    'en': {
      'feed': 'Feed',
      'login_register': 'Login / Register',
      'remember_user': 'Remember user',
      'login': 'Login',
      'register': 'Register',
      'settings': 'Settings',
      'dark_mode': 'Dark mode',
      'notifications': 'Notifications',
      'language': 'Language:',
      'export_db': 'Export database to JSON',
      'import_db': 'Import database from Documents/insta_export.json',
      'profile': 'Profile',
      'edit': 'Edit',
      'no_name': 'No name',
      'exported_to': 'Exported to {path} ({bytes} bytes)',
      'export_failed': 'Export failed: {err}',
      'no_import_file': 'No import file found in Documents',
      'import_completed': 'Import completed',
      'import_failed': 'Import failed: {err}',
      'post': 'Post',
      'likes': '{n} likes',
      'no_comments': 'No comments',
      'no_posts': 'No posts yet',
      'enter_description': 'Enter a description',
      'published': 'Published',
      'create_post': 'Create post',
      'description': 'Description',
      'publish': 'Publish',
      'invalid_credentials': 'Invalid credentials',
      'user_exists': 'User already exists',
      'save': 'Save',
      'logout': 'Logout',
        'export': 'Export',
        'import': 'Import',
    },
    'es': {
      'feed': 'Feed',
      'login_register': 'Login / Registro',
      'remember_user': 'Recordar usuario',
      'login': 'Login',
      'register': 'Register',
      'settings': 'Ajustes',
      'dark_mode': 'Modo oscuro',
      'notifications': 'Notificaciones',
      'language': 'Idioma:',
      'export_db': 'Exportar BD a JSON',
      'import_db': 'Importar BD desde Documents/insta_export.json',
      'profile': 'Perfil',
      'edit': 'Editar',
      'no_name': 'Sin nombre',
      'exported_to': 'Exportado a {path} ({bytes} bytes)',
      'export_failed': 'Error exportando: {err}',
      'no_import_file': 'No se encontró archivo de importación en Documents',
      'import_completed': 'Importación completada',
      'import_failed': 'Error importando: {err}',
      'post': 'Publicación',
      'likes': '{n} me gusta',
      'no_comments': 'No hay comentarios',
      'no_posts': 'Sin publicaciones aún',
      'enter_description': 'Introduce una descripción',
      'published': 'Publicado',
      'create_post': 'Crear publicación',
      'description': 'Descripción',
      'publish': 'Publicar',
      'invalid_credentials': 'Credenciales inválidas',
      'user_exists': 'Usuario ya existe',
      'save': 'Guardar',
      'logout': 'Cerrar sesión',
      'export': 'Exportar',
      'import': 'Importar',
    }
  };

  var s = _t[lang]?[key] ?? _t['en']?[key] ?? key;
  if (args != null) {
    args.forEach((k, v) {
      s = s.replaceAll('{$k}', v);
    });
  }
  return s;
}
