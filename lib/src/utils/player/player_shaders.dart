enum PlayerShaders {
  a('Anime4K_ModeA', 'glsl'),
  doubleA('Anime4K_ModeA_A', 'glsl'),
  b('Anime4K_ModeB', 'glsl'),
  doubleB('Anime4K_ModeB_B', 'glsl'),
  c('Anime4K_ModeC', 'glsl'),
  cPlusA('Anime4K_ModeC_A', 'glsl');

  final String fileName;
  final String fileExt;

  const PlayerShaders(
    this.fileName,
    this.fileExt,
  );

  String get nameAndExt {
    return '$fileName.$fileExt';
  }

  String get label {
    return switch (this) {
      PlayerShaders.a => 'Anime4K A',
      PlayerShaders.doubleA => 'Anime4K A+A',
      PlayerShaders.b => 'Anime4K B',
      PlayerShaders.doubleB => 'Anime4K B+B',
      PlayerShaders.c => 'Anime4K C',
      PlayerShaders.cPlusA => 'Anime4K C+A',
    };
  }
}
