import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class UsuarioForm extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final bool embedded;
  final bool viewOnly;
  UsuarioForm({this.usuario, this.embedded = false, this.viewOnly = false});

  @override
  _UsuarioFormState createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();

  final TextEditingController nombresCtrl = TextEditingController();
  final TextEditingController apellidosCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  // Campos específicos por rol
  final TextEditingController codigoEstudianteCtrl = TextEditingController();
  final TextEditingController semestreCtrl = TextEditingController();
  final TextEditingController codigoDocenteCtrl = TextEditingController();
  final TextEditingController especialidadCtrl = TextEditingController();
  final TextEditingController materiaCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _changePassword = false;
  int _activoValue = 1;

  List<dynamic> _roles = [];
  String? _selectedRolId;
  String? _selectedRolNombre;
  bool _loadingRoles = true;

  @override
  void initState() {
    super.initState();
    _cargarRoles();
    if (widget.usuario != null) {
      nombresCtrl.text = widget.usuario!['nombres'] ?? '';
      apellidosCtrl.text = widget.usuario!['apellidos'] ?? '';
      usernameCtrl.text = widget.usuario!['username'] ?? '';
      emailCtrl.text = widget.usuario!['email'] ?? '';
      _activoValue = widget.usuario!['activo'] ?? 1;

      // Cargar campos específicos del rol
      codigoEstudianteCtrl.text = widget.usuario!['codigo_estudiante'] ?? '';
      semestreCtrl.text = widget.usuario!['semestre']?.toString() ?? '';
      codigoDocenteCtrl.text = widget.usuario!['codigo_docente'] ?? '';
      especialidadCtrl.text = widget.usuario!['especialidad'] ?? '';
      materiaCtrl.text = widget.usuario!['materia'] ?? '';

      // Cargar rol principal
      if (widget.usuario!['rol_principal'] != null) {
        _selectedRolNombre = widget.usuario!['rol_principal'];
      }
    }
  }

  Future<void> _cargarRoles() async {
    try {
      final roles = await api.fetchRoles();
      setState(() {
        _roles = roles;
        _loadingRoles = false;

        // Si está editando y tiene rol principal, buscar el ID
        if (widget.usuario != null && _selectedRolNombre != null) {
          final rol = _roles.firstWhere(
            (r) => r['nombre'] == _selectedRolNombre,
            orElse: () => null,
          );
          if (rol != null) {
            _selectedRolId = rol['id'];
          }
        }
      });
    } catch (e) {
      setState(() {
        _loadingRoles = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar roles: $e')),
      );
    }
  }

  bool get isView => widget.viewOnly;
  bool get isEdit => widget.usuario != null && !isView;
  bool get isCreate => widget.usuario == null;

  @override
  Widget build(BuildContext context) {
    final formContent = Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isView
                  ? 'Ver Usuario'
                  : isCreate
                      ? 'Nuevo Usuario'
                      : 'Editar Usuario',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            // Información personal
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nombresCtrl,
                            readOnly: isView,
                            decoration: InputDecoration(
                              labelText: 'Nombres*',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.isEmpty == true ? 'Campo requerido' : null,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: apellidosCtrl,
                            readOnly: isView,
                            decoration: InputDecoration(
                              labelText: 'Apellidos*',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.isEmpty == true ? 'Campo requerido' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Selección de Rol
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asignación de Rol',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 16),
                    if (_loadingRoles)
                      Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRolId,
                        decoration: InputDecoration(
                          labelText: 'Rol*',
                          border: OutlineInputBorder(),
                          helperText: 'Seleccione el rol del usuario',
                        ),
                        items: _roles.map<DropdownMenuItem<String>>((rol) {
                          return DropdownMenuItem<String>(
                            value: rol['id'],
                            child: Text(rol['nombre']),
                          );
                        }).toList(),
                        onChanged: isView
                            ? null
                            : (String? newValue) {
                                setState(() {
                                  _selectedRolId = newValue;
                                  _selectedRolNombre = _roles.firstWhere(
                                      (r) => r['id'] == newValue)['nombre'];
                                });
                              },
                        validator: (v) =>
                            v == null ? 'Debe seleccionar un rol' : null,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Campos específicos según el rol seleccionado
            if (_selectedRolNombre == 'Estudiante')
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de Estudiante',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: codigoEstudianteCtrl,
                        readOnly: isView,
                        decoration: InputDecoration(
                          labelText: 'Código de Estudiante*',
                          border: OutlineInputBorder(),
                          helperText: 'Ej: EST2024001',
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: semestreCtrl,
                        readOnly: isView,
                        decoration: InputDecoration(
                          labelText: 'Semestre*',
                          border: OutlineInputBorder(),
                          helperText: 'Ej: 5',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Campo requerido';
                          final semestre = int.tryParse(v!);
                          if (semestre == null || semestre < 1 || semestre > 10)
                            return 'Ingrese un semestre válido (1-10)';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

            if (_selectedRolNombre == 'Docente')
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de Docente',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: codigoDocenteCtrl,
                        readOnly: isView,
                        decoration: InputDecoration(
                          labelText: 'Código de Docente*',
                          border: OutlineInputBorder(),
                          helperText: 'Ej: DOC2024001',
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: especialidadCtrl,
                        readOnly: isView,
                        decoration: InputDecoration(
                          labelText: 'Especialidad*',
                          border: OutlineInputBorder(),
                          helperText: 'Ej: Odontología General',
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: materiaCtrl,
                        readOnly: isView,
                        decoration: InputDecoration(
                          labelText: 'Materia*',
                          border: OutlineInputBorder(),
                          helperText:
                              'Ej: Periodoncia, Odontopediatría, Prostodoncia',
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Campo requerido' : null,
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Credenciales
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credenciales de Acceso',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: usernameCtrl,
                      readOnly: isView || isEdit,
                      decoration: InputDecoration(
                        labelText: 'Usuario*',
                        border: OutlineInputBorder(),
                        helperText:
                            isEdit ? 'El usuario no se puede cambiar' : null,
                      ),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Campo requerido';
                        if (v!.length < 3) return 'Mínimo 3 caracteres';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: emailCtrl,
                      readOnly: isView,
                      decoration: InputDecoration(
                        labelText: 'Email*',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Campo requerido';
                        if (!v!.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Contraseña (solo para crear o si se marca cambio)
                    if (isCreate || (isEdit && _changePassword)) ...[
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña*',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) {
                          if (isCreate && v?.isEmpty == true)
                            return 'Campo requerido';
                          if (_changePassword && v?.isEmpty == true)
                            return 'Campo requerido';
                          if (v != null && v.isNotEmpty && v.length < 6)
                            return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordCtrl,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Contraseña*',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) {
                          if (isCreate && v?.isEmpty == true)
                            return 'Campo requerido';
                          if (_changePassword && v?.isEmpty == true)
                            return 'Campo requerido';
                          if (v != passwordCtrl.text)
                            return 'Las contraseñas no coinciden';
                          return null;
                        },
                      ),
                    ],

                    // Opción de cambiar contraseña en edición
                    if (isEdit && !_changePassword)
                      TextButton.icon(
                        icon: Icon(Icons.lock_reset),
                        label: Text('Cambiar Contraseña'),
                        onPressed: () {
                          setState(() {
                            _changePassword = true;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Estado
            if (!isView)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: _activoValue,
                            onChanged: isView
                                ? null
                                : (val) {
                                    setState(() {
                                      _activoValue = val!;
                                    });
                                  },
                          ),
                          Text('Activo'),
                          SizedBox(width: 24),
                          Radio<int>(
                            value: 0,
                            groupValue: _activoValue,
                            onChanged: isView
                                ? null
                                : (val) {
                                    setState(() {
                                      _activoValue = val!;
                                    });
                                  },
                          ),
                          Text('Inactivo'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 24),

            // Información de vista (si está viendo)
            if (isView && widget.usuario != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Adicional',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      _buildInfoRow(
                          'Estado', _activoValue == 1 ? 'Activo' : 'Inactivo'),
                      _buildInfoRow('Creado',
                          widget.usuario!['creado_en']?.toString() ?? 'N/A'),
                      if (widget.usuario!['roles'] != null)
                        _buildInfoRow(
                            'Roles',
                            (widget.usuario!['roles'] as List)
                                .map((r) => r['nombre'])
                                .join(', ')),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 24),

            // Botones
            if (!isView)
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  try {
                    final data = {
                      'nombres': nombresCtrl.text,
                      'apellidos': apellidosCtrl.text,
                      'username': usernameCtrl.text,
                      'email': emailCtrl.text,
                      'activo': _activoValue,
                      'rol_id': _selectedRolId,
                    };

                    // Agregar campos según el rol
                    if (_selectedRolNombre == 'Estudiante') {
                      data['codigo_estudiante'] = codigoEstudianteCtrl.text;
                      data['semestre'] = int.tryParse(semestreCtrl.text) ?? 0;
                    } else if (_selectedRolNombre == 'Docente') {
                      data['codigo_docente'] = codigoDocenteCtrl.text;
                      data['especialidad'] = especialidadCtrl.text;
                      data['materia'] = materiaCtrl.text;
                    }

                    // Si es creación o se cambió la contraseña, incluirla
                    if (isCreate ||
                        (isEdit &&
                            _changePassword &&
                            passwordCtrl.text.isNotEmpty)) {
                      data['password'] = passwordCtrl.text;
                    }

                    if (isCreate) {
                      await api.createUsuario(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Usuario creado exitosamente')),
                      );
                    } else {
                      await api.updateUsuario(widget.usuario!['id'], data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Usuario actualizado exitosamente')),
                      );
                    }

                    if (widget.embedded) {
                      context.read<MenuAppController>().setPage('usuarios');
                    } else {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text('Guardar'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  if (widget.embedded) {
                    context.read<MenuAppController>().setPage('usuarios');
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text('Cerrar'),
              ),
          ],
        ),
      ),
    );

    if (widget.embedded) {
      return SingleChildScrollView(
        child: Card(margin: EdgeInsets.all(16), child: formContent),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isView
            ? 'Ver Usuario'
            : isCreate
                ? 'Nuevo Usuario'
                : 'Editar Usuario'),
      ),
      body: SingleChildScrollView(child: formContent),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nombresCtrl.dispose();
    apellidosCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    codigoEstudianteCtrl.dispose();
    semestreCtrl.dispose();
    codigoDocenteCtrl.dispose();
    especialidadCtrl.dispose();
    materiaCtrl.dispose();
    super.dispose();
  }
}
