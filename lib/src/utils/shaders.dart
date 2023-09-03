// ignore_for_file: constant_identifier_names

import 'package:path/path.dart' as p;

const String anime4K_Upscale_Original_x2 = 'Anime4K_Upscale_Original_x2.glsl';
const String anime4K_Upscale_DTD_x2 = 'Anime4K_Upscale_DTD_x2.glsl';
const String anime4K_Upscale_DoG_x2 = 'Anime4K_Upscale_DoG_x2.glsl';
const String anime4K_Upscale_Denoise_CNN_x2_VL =
    'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl';
const String anime4K_Upscale_Denoise_CNN_x2_UL =
    'Anime4K_Upscale_Denoise_CNN_x2_UL.glsl';
const String anime4K_Upscale_Denoise_CNN_x2_S =
    'Anime4K_Upscale_Denoise_CNN_x2_S.glsl';
const String anime4K_Upscale_Denoise_CNN_x2_M =
    'Anime4K_Upscale_Denoise_CNN_x2_M.glsl';
const String anime4K_Upscale_Denoise_CNN_x2_L =
    'Anime4K_Upscale_Denoise_CNN_x2_L.glsl';
const String anime4K_Upscale_Deblur_Original_x2 =
    'Anime4K_Upscale_Deblur_Original_x2.glsl';
const String anime4K_Upscale_Deblur_DoG_x2 =
    'Anime4K_Upscale_Deblur_DoG_x2.glsl';
const String anime4K_Upscale_CNN_x2_VL = 'Anime4K_Upscale_CNN_x2_VL.glsl';
const String anime4K_Upscale_CNN_x2_UL = 'Anime4K_Upscale_CNN_x2_UL.glsl';
const String anime4K_Upscale_CNN_x2_S = 'Anime4K_Upscale_CNN_x2_S.glsl';
const String anime4K_Upscale_CNN_x2_M = 'Anime4K_Upscale_CNN_x2_M.glsl';
const String anime4K_Upscale_CNN_x2_L = 'Anime4K_Upscale_CNN_x2_L.glsl';
const String anime4K_Thin_VeryFast = 'Anime4K_Thin_VeryFast.glsl';
const String anime4K_Thin_HQ = 'Anime4K_Thin_HQ.glsl';
const String anime4K_Thin_Fast = 'Anime4K_Thin_Fast.glsl';
const String anime4K_Restore_CNN_VL = 'Anime4K_Restore_CNN_VL.glsl';
const String anime4K_Restore_CNN_UL = 'Anime4K_Restore_CNN_UL.glsl';
const String anime4K_Restore_CNN_Soft_VL = 'Anime4K_Restore_CNN_Soft_VL.glsl';
const String anime4K_Restore_CNN_Soft_UL = 'Anime4K_Restore_CNN_Soft_UL.glsl';
const String anime4K_Restore_CNN_Soft_S = 'Anime4K_Restore_CNN_Soft_S.glsl';
const String anime4K_Restore_CNN_Soft_M = 'Anime4K_Restore_CNN_Soft_M.glsl';
const String anime4K_Restore_CNN_Soft_L = 'Anime4K_Restore_CNN_Soft_L.glsl';
const String anime4K_Restore_CNN_S = 'Anime4K_Restore_CNN_S.glsl';
const String anime4K_Restore_CNN_M = 'Anime4K_Restore_CNN_M.glsl';
const String anime4K_Restore_CNN_L = 'Anime4K_Restore_CNN_L.glsl';
const String anime4K_Denoise_Bilateral_Mode =
    'Anime4K_Denoise_Bilateral_Mode.glsl';
const String anime4K_Denoise_Bilateral_Median =
    'Anime4K_Denoise_Bilateral_Median.glsl';
const String anime4K_Denoise_Bilateral_Mean =
    'Anime4K_Denoise_Bilateral_Mean.glsl';
const String anime4K_Deblur_Original = 'Anime4K_Deblur_Original.glsl';
const String anime4K_Deblur_DoG = 'Anime4K_Deblur_DoG.glsl';
const String anime4K_Darken_VeryFast = 'Anime4K_Darken_VeryFast.glsl';
const String anime4K_Darken_HQ = 'Anime4K_Darken_HQ.glsl';
const String anime4K_Darken_Fast = 'Anime4K_Darken_Fast.glsl';
const String anime4K_Clamp_Highlights = 'Anime4K_Clamp_Highlights.glsl';
const String anime4K_AutoDownscalePre_x4 = 'Anime4K_AutoDownscalePre_x4.glsl';
const String anime4K_AutoDownscalePre_x2 = 'Anime4K_AutoDownscalePre_x2.glsl';

const String anime4K_Restore_GAN_UUL = 'Anime4K_Restore_GAN_UUL.glsl';
const String anime4K_Upscale_GAN_x4_UUL = 'Anime4K_Upscale_GAN_x4_UUL.glsl';

String _makePath(String basePath, String shader) {
  return '${p.join(basePath, 'shaders', shader)};';
}

String getShadersDir(String basePath) {
  return p.join(basePath, 'shaders');
}

///Optimized shaders for lower-end GPU:

String anime4kModeAFast(String basePath) {
  String str = '';

  str += _makePath(basePath, anime4K_Clamp_Highlights);
  str += _makePath(basePath, anime4K_Restore_CNN_M);
  str += _makePath(basePath, anime4K_Upscale_CNN_x2_M);
  str += _makePath(basePath, anime4K_AutoDownscalePre_x2);
  str += _makePath(basePath, anime4K_AutoDownscalePre_x4);
  str += _makePath(basePath, anime4K_Upscale_CNN_x2_S);

  str += _makePath(basePath, anime4K_Darken_Fast);
  str += _makePath(basePath, anime4K_Thin_Fast);

  return str;
  //return '$basePath/$anime4K_Clamp_Highlights;$basePath/$anime4K_Restore_CNN_M;$basePath/$anime4K_Upscale_CNN_x2_M;$basePath/$anime4K_AutoDownscalePre_x2;$basePath/$anime4K_AutoDownscalePre_x4;$basePath/$anime4K_Upscale_CNN_x2_S;';
}

String anime4kModeDoubleAFast(String basePath) {
  String str = '';

  str += _makePath(basePath, anime4K_Clamp_Highlights);
  str += _makePath(basePath, anime4K_Restore_CNN_M);
  str += _makePath(basePath, anime4K_Upscale_CNN_x2_M);
  str += _makePath(basePath, anime4K_Restore_CNN_S);
  str += _makePath(basePath, anime4K_AutoDownscalePre_x2);
  str += _makePath(basePath, anime4K_AutoDownscalePre_x4);
  str += _makePath(basePath, anime4K_Upscale_CNN_x2_S);

  str += _makePath(basePath, anime4K_Darken_VeryFast);
  str += _makePath(basePath, anime4K_Thin_Fast);

  return str;
  //return '$basePath/$anime4K_Clamp_Highlights;$basePath/$anime4K_Restore_CNN_M;$basePath/$anime4K_Upscale_CNN_x2_M;$basePath/$anime4K_Restore_CNN_S;$basePath/$anime4K_AutoDownscalePre_x2;$basePath/$anime4K_AutoDownscalePre_x4;$basePath/$anime4K_Upscale_CNN_x2_S;';
}

///Optimized shaders for higher-end GPU:

String anime4kModeDoubleA(String basePath) {
  String str = '';

  str += _makePath(basePath, anime4K_Clamp_Highlights);
  str += _makePath(basePath, anime4K_Restore_CNN_VL);
  str += _makePath(basePath, anime4K_Upscale_CNN_x2_VL);
  str += _makePath(basePath, anime4K_Restore_CNN_M);
  str += _makePath(basePath, anime4K_AutoDownscalePre_x2);
  str += _makePath(basePath, anime4K_AutoDownscalePre_x4);
  str += _makePath(basePath, anime4K_Upscale_CNN_x2_M);

  str += _makePath(basePath, anime4K_Darken_HQ);
  str += _makePath(basePath, anime4K_Thin_HQ);

  return str;
}

String anime4kModeGan(String basePath) {
  String str = '';

  str += _makePath(basePath, anime4K_Clamp_Highlights);
  str += _makePath(basePath, anime4K_Restore_GAN_UUL);
  str += _makePath(basePath, anime4K_Upscale_CNN_x2_VL);
  str += _makePath(basePath, anime4K_Restore_CNN_Soft_VL);
  str += _makePath(basePath, anime4K_AutoDownscalePre_x2);
  str += _makePath(basePath, anime4K_AutoDownscalePre_x4);
  str += _makePath(basePath, anime4K_Upscale_GAN_x4_UUL);

  str += _makePath(basePath, anime4K_Darken_HQ);
  str += _makePath(basePath, anime4K_Thin_HQ);

  return str;
}
