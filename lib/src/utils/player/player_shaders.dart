const int kPlayerShadersVersion = 1;

const List<PlayerShader> kPlayerShaders = [
  PlayerShader(
    id: 'grain',
    name: 'Grain',
    description:
        'Пленочное зерно. Скрывает артефакты сжатия и придает текстуру.',
    filePath: 'filmgrain.glsl',
  ),
  PlayerShader(
    id: 'bw',
    name: 'B/W',
    description: 'Классический черно-белый фильтр.',
    filePath: 'grayscale.glsl',
  ),
  // 4k Experimental-Effects
  PlayerShader(
    id: '4k-t-hq',
    name: 'Anime4K Thin',
    description: 'Делает линии на изображении тоньше.',
    filePath: 'Anime4K_Thin_HQ.glsl',
  ),
  PlayerShader(
    id: '4k-d-hq',
    name: 'Anime4K Darken',
    description: 'Затемняет линии на изображении.',
    filePath: 'Anime4K_Darken_HQ.glsl',
  ),
  // 4k mode a
  PlayerShader(
    id: '4k-a',
    name: 'Anime4K A',
    description: 'Для размытого видео. Делает контуры и детали четче.',
    filePath: 'Anime4K_ModeA.glsl',
    isExclusive: true,
  ),
  PlayerShader(
    id: '4k-a+a',
    name: 'Anime4K A+A',
    description:
        'Усиленная версия А. Максимальная четкость (высокая нагрузка).',
    filePath: 'Anime4K_ModeA_A.glsl',
    isExclusive: true,
  ),
  // 4k mode b
  PlayerShader(
    id: '4k-b',
    name: 'Anime4K B',
    description: 'Рекомендуемый шейдер для ПК.',
    filePath: 'Anime4K_ModeB.glsl',
    isExclusive: true,
  ),
  PlayerShader(
    id: '4k-b+b',
    name: 'Anime4K B+B',
    description: 'Усиленная версия B. Убирает визуальный шум и артефакты.',
    filePath: 'Anime4K_ModeB_B.glsl',
    isExclusive: true,
  ),
  // 4k mode c
  PlayerShader(
    id: '4k-c',
    name: 'Anime4K C',
    description: 'Для качественного видео. Аккуратное улучшение границ.',
    filePath: 'Anime4K_ModeC.glsl',
    isExclusive: true,
  ),
  PlayerShader(
    id: '4k-c+a',
    name: 'Anime4K C+A',
    description: 'Рекомендуемый шейдер для мобильных устройств.',
    filePath: 'Anime4K_ModeC_A.glsl',
    isExclusive: true,
  ),
];

class PlayerShader {
  final String id;
  final String name;
  final String? description;
  final String filePath;
  final bool isExclusive;

  const PlayerShader({
    required this.id,
    required this.name,
    this.description,
    required this.filePath,
    this.isExclusive = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerShader &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
