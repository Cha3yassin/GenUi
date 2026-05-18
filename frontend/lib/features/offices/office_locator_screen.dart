import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_providers.dart';
import '../../core/utils/async_value_widget.dart';
import '../../renderer/widgets/office_map_placeholder_block_widget.dart';
import '../../shared/models/office_model.dart';
import '../../shared/widgets/office_card.dart';
import '../../shared/widgets/section_header.dart';

class OfficeLocatorScreen extends ConsumerStatefulWidget {
  const OfficeLocatorScreen({this.stepId, super.key});

  final String? stepId;

  @override
  ConsumerState<OfficeLocatorScreen> createState() =>
      _OfficeLocatorScreenState();
}

class _OfficeLocatorScreenState extends ConsumerState<OfficeLocatorScreen> {
  double? _lat;
  double? _lng;
  bool _isLocating = false;
  String? _locationMessage;

  @override
  Widget build(BuildContext context) {
    final query = (stepId: widget.stepId, lat: _lat, lng: _lng);
    final officesValue = ref.watch(nearbyOfficesProvider(query));
    final hasCurrentLocation = _lat != null && _lng != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Localisation des services')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OfficeMapPlaceholderBlockWidget(
                data: {
                  'title': hasCurrentLocation
                      ? 'Services proches de votre position'
                      : 'Services autour de Tunis',
                  'subtitle': hasCurrentLocation
                      ? 'Position: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'
                      : 'Appuyez sur le bouton orange pour utiliser votre position actuelle.',
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLocating ? null : _findNearestOffice,
                  icon: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.near_me_rounded),
                  label: Text(
                    _isLocating
                        ? 'Recherche de votre position...'
                        : 'Trouver le bureau le plus proche',
                  ),
                ),
              ),
              if (_locationMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _locationMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Bureaux recommandés',
                subtitle: hasCurrentLocation
                    ? 'Triés selon votre position actuelle.'
                    : 'Triés depuis une position par défaut à Tunis.',
              ),
              const SizedBox(height: 14),
              AsyncValueWidget<List<OfficeModel>>(
                value: officesValue,
                data: (offices) {
                  if (offices.isEmpty) {
                    return const _EmptyOfficeList();
                  }

                  return Column(
                    children: [
                      for (var index = 0; index < offices.length; index++) ...[
                        OfficeCard(office: offices[index]),
                        if (index == 0) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _openDirections(offices[index]),
                              icon: const Icon(Icons.map_rounded),
                              label: const Text('Ouvrir sur la carte'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _findNearestOffice() async {
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });

    try {
      final position = await _getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _locationMessage =
            'Position détectée. Calcul du bureau le plus proche...';
      });

      final offices = await ref.read(apiServiceProvider).getNearbyOffices(
            stepId: widget.stepId,
            lat: position.latitude,
            lng: position.longitude,
          );

      if (!mounted || offices.isEmpty) return;
      await _openDirections(offices.first);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _locationMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Activez la localisation puis réessayez.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permission de localisation refusée.');
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception(
        'Permission bloquée. Activez la localisation dans les paramètres.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      rethrow;
    }
  }

  Future<void> _openDirections(OfficeModel office) async {
    if (office.lat == null || office.lng == null) {
      setState(() {
        _locationMessage = 'Coordonnées indisponibles pour ce bureau.';
      });
      return;
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${office.lat},${office.lng}',
      'travelmode': 'driving',
    });

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      setState(() {
        _locationMessage = 'Impossible d’ouvrir la carte sur cet appareil.';
      });
    }
  }
}

class _EmptyOfficeList extends StatelessWidget {
  const _EmptyOfficeList();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'Aucun bureau trouvé pour ce service.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
