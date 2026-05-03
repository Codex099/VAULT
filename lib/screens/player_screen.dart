import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';
import '../services/stream_service.dart';
import '../widgets/source_switcher.dart';

class PlayerScreen extends StatefulWidget {
  final String imdbId;
  final Map<String, dynamic> extra;

  const PlayerScreen({super.key, required this.imdbId, required this.extra});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late WebViewController _controller;
  StreamSource _source = StreamSource.streamImdb;

  bool _loading = true;
  bool _overlayVisible = true;
  DateTime? _watchStartTime;

  // VLC-style gestures
  double _brightness = 0.5;
  double _volume = 0.5;
  bool _showBrightnessHUD = false;
  bool _showVolumeHUD = false;
  Timer? _hudTimer;
  Timer? _hideOverlayTimer;

  // Pinch-to-zoom
  double _scale = 1.0;
  double _baseScale = 1.0;
  bool _showZoomHUD = false;
  Timer? _zoomHudTimer;
  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;

  String get _type => widget.extra['type'] as String? ?? 'movie';
  String get _title => widget.extra['title'] as String? ?? '';
  int get _season => widget.extra['season'] as int? ?? 1;
  int get _episode => widget.extra['episode'] as int? ?? 1;
  String get _tmdbId => widget.extra['tmdbId'] as String? ?? '';
  String get _posterUrl => widget.extra['posterUrl'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    _enterFullscreen();
    _initWebView();
    _initSystemValues();
    _watchStartTime = DateTime.now();
    _controller.loadRequest(Uri.parse(_urlForSource(_source)));
    _startHideOverlayTimer();
  }

  String _urlForSource(StreamSource source) {
    if (_type == 'youtube') return widget.extra['url'] as String? ?? '';
    if (_type == 'series') {
      return StreamService.getSeriesUrl(widget.imdbId, _tmdbId, _season, _episode, source);
    }
    return StreamService.getMovieUrl(widget.imdbId, _tmdbId, source);
  }

  Future<void> _initSystemValues() async {
    try {
      _brightness = await ScreenBrightness().current;
      _volume = await FlutterVolumeController.getVolume() ?? 0.5;
      FlutterVolumeController.addListener((v) {
        if (mounted) setState(() => _volume = v);
      });
    } catch (_) {}
  }

  void _startHideOverlayTimer() {
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _overlayVisible) {
        setState(() => _overlayVisible = false);
      }
    });
  }

  void _handleVerticalDrag(DragUpdateDetails details) {
    final width = MediaQuery.of(context).size.width;
    final isLeft = details.globalPosition.dx < width / 2;
    // Haut = augmenter, Bas = diminuer
    final delta = -details.primaryDelta! / MediaQuery.of(context).size.height;

    if (isLeft) {
      _updateVolume(delta);
    } else {
      _updateBrightness(delta);
    }
  }

  void _updateBrightness(double delta) async {
    _brightness = (_brightness + delta).clamp(0.0, 1.0);
    try {
      await ScreenBrightness().setScreenBrightness(_brightness);
      _showHUD('brightness');
    } catch (_) {}
  }

  void _updateVolume(double delta) async {
    _volume = (_volume + delta).clamp(0.0, 1.0);
    await FlutterVolumeController.setVolume(_volume);
    _showHUD('volume');
  }

  void _showHUD(String type) {
    setState(() {
      if (type == 'brightness') {
        _showBrightnessHUD = true;
        _showVolumeHUD = false;
      } else {
        _showVolumeHUD = true;
        _showBrightnessHUD = false;
      }
    });
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() { _showBrightnessHUD = false; _showVolumeHUD = false; });
    });
  }

  // ── Zoom ──────────────────────────────────────────────
  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return; // pincement uniquement (2 doigts)
    final newScale = (_baseScale * details.scale).clamp(_minScale, _maxScale);
    if ((newScale - _scale).abs() < 0.005) return; // seuil minimal
    _scale = newScale;
    _applyZoom();
    _showZoomIndicator();
  }

  void _applyZoom() {
    final js = '''
      (function() {
        var el = document.body;
        el.style.transformOrigin = '50%% 50%%';
        el.style.transform = 'scale($_scale)';
        el.style.overflow = 'hidden';
        var vids = document.querySelectorAll('video, iframe');
        vids.forEach(function(v) {
          v.style.transformOrigin = '50%% 50%%';
          v.style.transform = 'scale($_scale)';
          v.style.width = '100vw';
          v.style.height = '100vh';
          v.style.position = 'fixed';
          v.style.top = '0';
          v.style.left = '0';
          v.style.zIndex = '9999';
        });
      })();
    ''';
    _controller.runJavaScript(js);
  }

  void _resetZoom() {
    _scale = 1.0;
    _baseScale = 1.0;
    _applyZoom();
    _showZoomIndicator();
  }

  void _showZoomIndicator() {
    setState(() => _showZoomHUD = true);
    _zoomHudTimer?.cancel();
    _zoomHudTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showZoomHUD = false);
    });
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    // Petit délai pour que les insets système se recalculent avant le rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
      ));
    });
  }

  void _initWebView() {
    _controller = WebViewController();
    if (!kIsWeb) _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
          _saveToHistory();
        },
      ));
  }

  void _switchSource(StreamSource source) {
    setState(() { _source = source; _loading = true; });
    _controller.loadRequest(Uri.parse(_urlForSource(source)));
  }

  void _saveToHistory() {
    final pp = context.read<ProgressProvider>();
    pp.addToHistory(
      imdbId: widget.imdbId,
      tmdbId: _tmdbId,
      title: _title,
      posterUrl: _posterUrl,
      type: _type == 'series' ? 'series' : 'movie',
      season: _type == 'series' ? _season : null,
      episode: _type == 'series' ? _episode : null,
    );
  }

  @override
  void dispose() {
    _hudTimer?.cancel();
    _hideOverlayTimer?.cancel();
    _zoomHudTimer?.cancel();
    FlutterVolumeController.removeListener();
    _exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitFullscreen();
        context.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            setState(() => _overlayVisible = !_overlayVisible);
            if (_overlayVisible) _startHideOverlayTimer();
          },
          onDoubleTap: _resetZoom,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onVerticalDragUpdate: _scale == 1.0 ? _handleVerticalDrag : null,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              
              // HUDs
              if (_showBrightnessHUD || _showVolumeHUD)
                _buildModernHUD(),

              // Zoom HUD
              if (_showZoomHUD)
                _buildZoomHUD(),
  
              // Loading
              if (_loading)
                _buildLoadingOverlay(),
  
              // Controls
              if (_overlayVisible)
                _buildControlsOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHUD() {
    final isBrightness = _showBrightnessHUD;
    final value = isBrightness ? _brightness : _volume;

    final IconData icon = isBrightness
        ? (value > 0.6 ? Icons.brightness_7_rounded : (value > 0.3 ? Icons.brightness_6_rounded : Icons.brightness_4_rounded))
        : (value > 0.5 ? Icons.volume_up_rounded : (value > 0 ? Icons.volume_down_rounded : Icons.volume_off_rounded));

    final String label = '${(value * 100).toInt()}%';

    // HUD latéral : gauche pour volume, droite pour luminosité
    final double? hudLeft = isBrightness ? null : 24;
    final double? hudRight = isBrightness ? 24 : null;

    return Positioned(
      left: hudLeft,
      right: hudRight,
      top: 0,
      bottom: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Barre verticale de progression
                  SizedBox(
                    height: 120,
                    width: 4,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white12,
                        color: AppColors.accent,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(icon, color: Colors.white, size: 28).animate().scale(),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomHUD() {
    final isReset = _scale <= 1.01;
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isReset ? Colors.white24 : AppColors.accent.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isReset ? Icons.zoom_in_rounded : Icons.zoom_out_map_rounded,
                    color: isReset ? Colors.white60 : AppColors.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isReset ? '1× — Normal' : '${_scale.toStringAsFixed(1)}×',
                    style: TextStyle(
                      color: isReset ? Colors.white60 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (!isReset) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'Double-tap pour réinitialiser',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 150.ms);
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
            const SizedBox(height: 24),
            Text(
              'INITIALISATION DU FLUX...',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2),
            ),
          ],
        ),
      ),
    ).animate().fadeOut(duration: 400.ms);
  }

  Widget _buildControlsOverlay() {
    return AnimatedOpacity(
      opacity: _overlayVisible ? 1.0 : 0.0,
      duration: AppDurations.fast,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            // Top Bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () { _exitFullscreen(); context.pop(); },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title.toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, letterSpacing: 1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_type == 'series')
                            Text(
                              'SAISON $_season • ÉPISODE $_episode',
                              style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                    _buildSourceBadge(),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Bottom Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_rounded, color: Colors.white),
                    onPressed: () => _controller.reload(),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => SourceSwitcher.show(context, current: _source, onSelect: _switchSource),
                    icon: const Icon(Icons.layers_rounded, color: Colors.white, size: 20),
                    label: const Text('SERVEURS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(backgroundColor: Colors.white10, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        StreamService.getSourceLabel(_source).toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
