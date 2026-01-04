import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/children_repository.dart';
import '../bloc/children_bloc.dart';

class ChildFormPage extends StatelessWidget {
  final String? childId;

  const ChildFormPage({super.key, this.childId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChildrenBloc>(),
      child: _ChildFormView(childId: childId),
    );
  }
}

class _ChildFormView extends StatefulWidget {
  final String? childId;

  const _ChildFormView({this.childId});

  @override
  State<_ChildFormView> createState() => _ChildFormViewState();
}

class _ChildFormViewState extends State<_ChildFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _birthDate;
  DisabilityType? _disabilityType;

  bool get isEditing => widget.childId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 5),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de nacimiento')),
      );
      return;
    }

    final birthDateStr = DateFormat('yyyy-MM-dd').format(_birthDate!);

    if (isEditing) {
      context.read<ChildrenBloc>().add(UpdateChildEvent(
        widget.childId!,
        UpdateChildParams(
          name: _nameController.text.trim(),
          birthDate: birthDateStr,
          disabilityType: _disabilityType,
          notes: _notesController.text.trim().isNotEmpty 
              ? _notesController.text.trim() 
              : null,
        ),
      ));
    } else {
      context.read<ChildrenBloc>().add(CreateChildEvent(
        CreateChildParams(
          name: _nameController.text.trim(),
          birthDate: birthDateStr,
          disabilityType: _disabilityType,
          notes: _notesController.text.trim().isNotEmpty 
              ? _notesController.text.trim() 
              : null,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildrenBloc, ChildrenState>(
      listener: (context, state) {
        if (state is ChildCreatedState || state is ChildUpdatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Perfil actualizado' : 'Perfil creado'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is ChildrenErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Editar perfil' : 'Nuevo perfil'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nombre
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.name,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: AppDimensions.space),
                
                // Fecha de nacimiento
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      _birthDate != null
                          ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                          : 'Seleccionar fecha',
                      style: _birthDate != null
                          ? AppTypography.bodyLarge
                          : AppTypography.bodyLarge.copyWith(
                              color: AppColors.textHint,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space),
                
                // Tipo de discapacidad
                Text('Tipo de discapacidad (opcional)', 
                    style: AppTypography.labelLarge),
                const SizedBox(height: AppDimensions.spaceS),
                Wrap(
                  spacing: AppDimensions.spaceS,
                  children: [
                    _DisabilityChip(
                      label: 'Ninguna',
                      isSelected: _disabilityType == null,
                      onTap: () => setState(() => _disabilityType = null),
                    ),
                    ...DisabilityType.values.map((type) => _DisabilityChip(
                      label: type.displayName,
                      isSelected: _disabilityType == type,
                      onTap: () => setState(() => _disabilityType = type),
                    )),
                  ],
                ),
                const SizedBox(height: AppDimensions.space),
                
                // Notas
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Información adicional...',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                
                // Botón
                BlocBuilder<ChildrenBloc, ChildrenState>(
                  builder: (context, state) {
                    final isLoading = state is ChildrenLoadingState;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _onSubmit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isEditing ? 'Guardar cambios' : 'Crear perfil'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisabilityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DisabilityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}
