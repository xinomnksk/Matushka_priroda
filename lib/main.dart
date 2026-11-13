import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MatushkaPrirodaApp());
}

class MatushkaPrirodaApp extends StatelessWidget {
  const MatushkaPrirodaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matushka Priroda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF351903),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class SoundTrack {
  final String title;
  final String assetPath;
  final IconData icon;
  final AudioPlayer player;
  double volume;
  bool isStarted;

  SoundTrack({
    required this.title,
    required this.assetPath,
    required this.icon,
  })  : player = AudioPlayer(),
        volume = 0.0,
        isStarted = false {
    player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      ),
    );
  }
}

class SoundCategory {
  final String name;
  final IconData icon;
  final GlobalKey sectionKey;
  final List<SoundTrack> tracks;

  SoundCategory({
    required this.name,
    required this.icon,
    required this.tracks,
  }) : sectionKey = GlobalKey();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color bgPrimary = Color(0xFF351903);
  static const Color bgCard = Color(0xFF365004);
  static const Color accentGreen = Color(0xFF8DA432);
  static const Color textFlax = Color(0xFFEDE383);

  late final List<SoundCategory> categories;
  final ScrollController _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;

  static const int defaultSeconds = 25 * 60;
  int remainingSeconds = defaultSeconds;
  Timer? _timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    categories = [
      SoundCategory(
        name: 'Природа',
        icon: Icons.park_rounded,
        tracks: [
          SoundTrack(
            title: 'Лес',
            assetPath: 'audios/forest.mp3',
            icon: Icons.forest_rounded,
          ),
          SoundTrack(
            title: 'Дождь',
            assetPath: 'audios/rain.mp3',
            icon: Icons.water_drop_rounded,
          ),
          SoundTrack(
            title: 'Костер',
            assetPath: 'audios/fire.mp3',
            icon: Icons.local_fire_department_rounded,
          ),
          SoundTrack(
            title: 'Ветер',
            assetPath: 'audios/wind.mp3',
            icon: Icons.air_rounded,
          ),
        ],
      ),
      SoundCategory(
        name: 'Город',
        icon: Icons.location_city_rounded,
        tracks: [
          SoundTrack(
            title: 'Город',
            assetPath: 'audios/city.mp3',
            icon: Icons.apartment_rounded,
          ),
          SoundTrack(
            title: 'Поезд',
            assetPath: 'audios/train.mp3',
            icon: Icons.train_rounded,
          ),
          SoundTrack(
            title: 'Трасса',
            assetPath: 'audios/cars.mp3',
            icon: Icons.directions_car_rounded,
          ),
          SoundTrack(
            title: 'Стройка',
            assetPath: 'audios/stroika.mp3',
            icon: Icons.construction_rounded,
          ),
        ],
      ),
      SoundCategory(
        name: 'Шумы',
        icon: Icons.graphic_eq_rounded,
        tracks: [
          SoundTrack(
            title: 'Белый шум',
            assetPath: 'audios/white_noise.mp3',
            icon: Icons.waves_rounded,
          ),
          SoundTrack(
            title: 'Розовый шум',
            assetPath: 'audios/pink_noise.mp3',
            icon: Icons.blur_on_rounded,
          ),
          SoundTrack(
            title: 'Коричневый',
            assetPath: 'audios/brown_noise.mp3',
            icon: Icons.grain_rounded,
          ),
          SoundTrack(
            title: 'Стиралка',
            assetPath: 'audios/stiralka.mp3',
            icon: Icons.local_laundry_service_rounded,
          ),
        ],
      ),
      SoundCategory(
        name: 'Частоты',
        icon: Icons.multitrack_audio_rounded,
        tracks: [
          SoundTrack(
            title: 'Альфа',
            assetPath: 'audios/alpha.mp3',
            icon: Icons.self_improvement_rounded,
          ),
          SoundTrack(
            title: 'Тета',
            assetPath: 'audios/theta.mp3',
            icon: Icons.psychology_rounded,
          ),
          SoundTrack(
            title: 'Дельта',
            assetPath: 'audios/delta.mp3',
            icon: Icons.nightlight_round,
          ),
          SoundTrack(
            title: 'Шуман 7 Гц',
            assetPath: 'audios/shuman7Hz.mp3',
            icon: Icons.public_rounded,
          ),
        ],
      ),
    ];
  }
  Future<void> _updateTrackVolume(SoundTrack track, double newVol) async {
    setState(() {
      track.volume = newVol;
    });

    try {
      if (newVol > 0.01) {
        if (!track.isStarted) {
          track.isStarted = true;
          await track.player.setReleaseMode(ReleaseMode.loop);
          await track.player.setVolume(newVol);
          await track.player.play(AssetSource(track.assetPath));
        } else {
          await track.player.setVolume(newVol);
          if (track.player.state != PlayerState.playing) {
            await track.player.resume();
          }
        }
      } else if (track.isStarted) {
        await track.player.setVolume(0.0);
        await track.player.pause();
      }
    } catch (e) {
      debugPrint('Audio error (${track.title}): $e');
    }
  }

  Future<void> _stopAllSounds() async {
    for (final category in categories) {
      for (final track in category.tracks) {
        if (track.isStarted) {
          await track.player.setVolume(0.0);
          await track.player.pause();
        }
      }
    }
    setState(() {
      for (final category in categories) {
        for (final track in category.tracks) {
          track.volume = 0.0;
        }
      }
    });
  }

  bool get _hasAnyActiveSound {
    for (final category in categories) {
      for (final track in category.tracks) {
        if (track.volume > 0.01) return true;
      }
    }
    return false;
  }

  void _scrollToCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    final targetContext = categories[index].sectionKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToNextCategory() {
    final nextIndex = (_selectedCategoryIndex + 1) % categories.length;
    _scrollToCategory(nextIndex);
  }

  void _toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
      setState(() => isRunning = false);
    } else {
      setState(() => isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds > 0) {
          setState(() => remainingSeconds--);
        } else {
          timer.cancel();
          setState(() {
            isRunning = false;
            remainingSeconds = defaultSeconds;
          });
          _stopAllSounds();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = defaultSeconds;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    for (final category in categories) {
      for (final track in category.tracks) {
        track.player.dispose();
      }
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: _scrollToNextCategory,
        backgroundColor: accentGreen,
        foregroundColor: bgPrimary,
        tooltip: 'Следующий раздел',
        child: Icon(
          _selectedCategoryIndex == categories.length - 1
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: 28,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    'Matushka Priroda',
                    style: TextStyle(
                      color: textFlax,
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: _hasAnyActiveSound
                        ? IconButton(
                            onPressed: _stopAllSounds,
                            icon: const Icon(Icons.volume_off_rounded,
                                color: accentGreen),
                            tooltip: 'Выключить все звуки',
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(remainingSeconds),
                          style: const TextStyle(
                            color: textFlax,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Фокус-сессия',
                          style: TextStyle(
                            color: accentGreen,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _resetTimer,
                          icon: const Icon(Icons.refresh_rounded,
                              color: textFlax),
                          tooltip: 'Сбросить таймер',
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: _toggleTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: bgPrimary,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(13),
                          ),
                          child: Icon(
                            isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () => _scrollToCategory(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? accentGreen : bgCard,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              category.icon,
                              size: 16,
                              color: isSelected ? bgPrimary : textFlax,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected ? bgPrimary : textFlax,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 72),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.map((category) {
                      return Column(
                        key: category.sectionKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 6, bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: bgCard.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(category.icon,
                                    size: 18, color: accentGreen),
                                const SizedBox(width: 8),
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    color: textFlax,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                                                    GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.02,
                            ),
                            itemCount: category.tracks.length,
                            itemBuilder: (context, idx) {
                              final track = category.tracks[idx];
                              final isActive = track.volume > 0.01;
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bgCard,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isActive
                                        ? accentGreen
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      track.icon,
                                      size: 34,
                                      color: isActive ? accentGreen : textFlax,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      track.title,
                                      style: const TextStyle(
                                        color: textFlax,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: accentGreen,
                                        inactiveTrackColor: bgPrimary,
                                        thumbColor: textFlax,
                                        overlayColor:
                                            accentGreen.withValues(alpha: 0.2),
                                      ),
                                      child: Slider(
                                        value: track.volume,
                                        min: 0.0,
                                        max: 1.0,
                                        onChanged: (val) =>
                                            _updateTrackVolume(track, val),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
