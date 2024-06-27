import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';

const MAPBOX_DOWNLOADS_TOKEN = 'sk.emyJ1IjoibWlnb2JlciIsImEiOiJjbHgwd3I1aTgwNTg3MmlzOWIwa2M4enh3In0.jcbAHxyPJ9GGEcAK78Ut3w';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late MapboxMapController _mapController;
  bool _isNavigating = false;
  bool _routeBuilt = false;
  bool _arrived = false;
  double? _distanceRemaining;
  double? _durationRemaining;
  String? _instruction;
  bool _isMultipleStop = false;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    MapBoxNavigation.instance.registerRouteEventListener(_onRouteEvent);
  }

  void requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildMap(),
          buildBottomPanel(),
        ],
      ),
    );
  }

  Widget buildMap() {
    return MapboxMap(
      accessToken: MAPBOX_DOWNLOADS_TOKEN,
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: CameraPosition(target: LatLng(1.2878, 103.8666), zoom: 13),
    );
  }

  Widget buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                startNavigation();
              },
              child: const Text('Start Navigation'),
            ),
            if (_isNavigating)
              Column(
                children: [
                  Text('Distance remaining: ${_distanceRemaining?.toStringAsFixed(2)} meters'),
                  Text('Duration remaining: ${_durationRemaining?.toStringAsFixed(2)} minutes'),
                  Text('Instruction: $_instruction'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> startNavigation() async {
    final cityHall = WayPoint(name: "City Hall", latitude: 42.886448, longitude: -78.878372);
    final downtown = WayPoint(name: "Downtown Buffalo", latitude: 42.8866177, longitude: -78.8814924);

    var wayPoints = [cityHall, downtown];

    await MapBoxNavigation.instance.startNavigation(
      wayPoints: wayPoints,
      options: MapBoxOptions(
        initialLatitude: 42.886448,
        initialLongitude: -78.878372,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRouter: false,
        simulateRoute: true,
        longPressDestinationEnabled: true,
        language: "pt",
      ),
    );
  }

  void _onRouteEvent(e) async {
    _distanceRemaining = await MapBoxNavigation.instance.distanceRemaining;
    _durationRemaining = await MapBoxNavigation.instance.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null) {
          _instruction = progressEvent.currentStepInstruction;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await MapBoxNavigation.instance.finishNavigation();
        }
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    setState(() {});
  }
}

class MapBoxNavigation {
  static final MapBoxNavigation instance = MapBoxNavigation._();

  MapBoxNavigation._();

  Future<void> startNavigation({required List<WayPoint> wayPoints, required MapBoxOptions options}) async {
    // Simulação de chamada ao SDK da Mapbox para iniciar a navegação
    // Substitua isso com a chamada real ao SDK da Mapbox
  }

  void registerRouteEventListener(Function(dynamic) listener) {
    // Simulação de registro de listener de evento de rota
    // Substitua isso com a chamada real ao SDK da Mapbox
  }

  Future<double?> get distanceRemaining async {
    // Simulação de obtenção da distância restante
    // Substitua isso com a chamada real ao SDK da Mapbox
    return 1000.0; // Exemplo de valor de retorno
  }

  Future<double?> get durationRemaining async {
    // Simulação de obtenção da duração restante
    // Substitua isso com a chamada real ao SDK da Mapbox
    return 10.0; // Exemplo de valor de retorno
  }

  Future<void> finishNavigation() async {
    // Simulação de chamada ao SDK da Mapbox para finalizar a navegação
    // Substitua isso com a chamada real ao SDK da Mapbox
  }
}

class WayPoint {
  final String name;
  final double latitude;
  final double longitude;

  WayPoint({required this.name, required this.latitude, required this.longitude});
}

class MapBoxOptions {
  final double initialLatitude;
  final double initialLongitude;
  final double zoom;
  final double tilt;
  final double bearing;
  final bool enableRefresh;
  final bool alternatives;
  final bool voiceInstructionsEnabled;
  final bool bannerInstructionsEnabled;
  final bool allowsUTurnAtWayPoints;
  final MapBoxNavigationMode mode;
  final VoiceUnits units;
  final bool simulateRouter;
  final bool simulateRoute;
  final bool longPressDestinationEnabled;
  final String language;

  MapBoxOptions({
    required this.initialLatitude,
    required this.initialLongitude,
    required this.zoom,
    required this.tilt,
    required this.bearing,
    required this.enableRefresh,
    required this.alternatives,
    required this.voiceInstructionsEnabled,
    required this.bannerInstructionsEnabled,
    required this.allowsUTurnAtWayPoints,
    required this.mode,
    required this.units,
    required this.simulateRouter,
    required this.simulateRoute,
    required this.longPressDestinationEnabled,
    required this.language,
  });
}

enum MapBoxNavigationMode { drivingWithTraffic }

enum VoiceUnits { imperial }

class MapBoxEvent {
  static const progress_change = "progress_change";
  static const route_building = "route_building";
  static const route_built = "route_built";
  static const route_build_failed = "route_build_failed";
  static const navigation_running = "navigation_running";
  static const on_arrival = "on_arrival";
  static const navigation_finished = "navigation_finished";
  static const navigation_cancelled = "navigation_cancelled";
}

class RouteProgressEvent {
  final bool arrived;
  final String? currentStepInstruction;

  RouteProgressEvent({required this.arrived, this.currentStepInstruction});
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
