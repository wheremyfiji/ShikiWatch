import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';

import '../../anime_soures/anime365/anime365_provider.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../../anime365/anime365.dart';
import '../../../../utils/app_utils.dart';

import 'setting_option.dart';

class Anime365Option extends ConsumerWidget {
  const Anime365Option({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(anime365UserProvider);

    return userAsync.when(
      data: (user) {
        final isLogined = user.isLogined;

        if (!isLogined) {
          return SettingsOption(
            title: 'Войти в аккаунт Anime365',
            subtitle: 'Требуется действующая подписка',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.navigator.push(PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const _Anime365LoginPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ));
            },
          );
        }

        final premiumUntilFormatted =
            DateFormat.yMMMEd().add_Hm().format(user.premiumUntil);

        final premium = user.isPremium
            ? 'Премиум до: $premiumUntilFormatted'
            : 'Премиум подписка не найдена';

        return SettingsOption(
          title: 'Anime365',
          subtitle: '${user.name} \n$premium',
          trailing: const Icon(Icons.logout_rounded),
          onTap: () async {
            bool? logout = await showDialog<bool>(
              barrierDismissible: false,
              context: context,
              builder: (context) => const _LogoutDialog(),
            );

            if (!(logout ?? false)) {
              return;
            }

            await ref.read(anime365Provider).logout();
            ref.invalidate(anime365UserProvider);
          },
        );
      },
      error: (_, __) => SettingsOption(
        title: 'Войти в аккаунт Anime365',
        subtitle: 'Ошибка: $_',
        onTap: () => ref.refresh(anime365UserProvider),
      ),
      loading: () => const SettingsOption(
        title: 'Войти в аккаунт Anime365',
        subtitle: 'Требуется действующая подписка',
        trailing: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.logout_rounded),
      title: const Text('Выйти из аккаунта?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Выход'),
        ),
      ],
    );
  }
}

class _Anime365LoginPage extends ConsumerStatefulWidget {
  const _Anime365LoginPage();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Anime365LoginPageState();
}

class _Anime365LoginPageState extends ConsumerState<_Anime365LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailRegExp = RegExp(
      //r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+"
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

  final model = _LoginFormModel(
    email: '',
    password: '',
  );

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      _loginButtonControllerProvider,
      (_, state) => state.whenOrNull(
        error: (error, stackTrace) {
          showErrorSnackBar(
            ctx: context,
            msg: error.toString(),
          );
        },
      ),
    );

    final loginState = ref.watch(_loginButtonControllerProvider);
    final isLoading = loginState is AsyncLoading<void>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход в аккаунт Anime365'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          canPop: !isLoading,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      filled: false,
                      border: OutlineInputBorder(),
                      labelText: 'Почта',
                      hintText: '',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Введи свою почту';
                      }

                      if (!_emailRegExp.hasMatch(value)) {
                        return 'Неверная почта!';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }

                      model.email = value;
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    autocorrect: false,
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: const InputDecoration(
                      filled: false,
                      border: OutlineInputBorder(),
                      labelText: 'Пароль',
                      hintText: '',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Введи свой пароль';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }

                      model.password = value;
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: _LoginButton(
                          isLoading: isLoading,
                          onPressed: () async {
                            if (_formKey.currentState == null) {
                              return;
                            }

                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              await ref
                                  .read(_loginButtonControllerProvider.notifier)
                                  .login(
                                    email: model.email,
                                    password: model.password,
                                    onFinally: () => context.navigator.pop(),
                                  );

                              ref.invalidate(anime365UserProvider);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      IconButton.filledTonal(
                        onPressed: () {
                          launchUrlString(
                            'https://smotret-anime.org/help',
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.help_outline),
                      ),
                    ],
                  ),
                  // const Spacer(),
                  const SizedBox(height: 24.0),
                  Center(
                    child: Text(
                      'Нажимая войти, ты принимаешь на себя риск, связанный с возможной блокировкой аккаунта.\nАвтор приложения не несет ответственности за это, а также не сохраняет ни в каком виде твою почту и пароль.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            )
          : const Text(
              'Войти',
            ),
    );
  }
}

final _loginButtonControllerProvider =
    StateNotifierProvider.autoDispose<_LoginButtonController, AsyncValue<void>>(
        (ref) {
  final api = ref.watch(anime365Provider);
  return _LoginButtonController(api: api);
});

class _LoginButtonController extends StateNotifier<AsyncValue<void>> {
  _LoginButtonController({required this.api})
      : super(const AsyncValue.data(null));
  final Anime365Api api;

  Future<void> login({
    required String email,
    required String password,
    required VoidCallback onFinally,
  }) async {
    try {
      state = const AsyncValue.loading();
      final r = await api.auth(email: email, password: password);
      if (r) {
        onFinally();
      } else {
        state = AsyncValue.error(_wrongAuth, StackTrace.current);
      }
    } on Anime365AuthException catch (e, s) {
      state = AsyncValue.error(e, s);
    } catch (e, s) {
      state = AsyncValue.error(_wrongAuth, s);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  static const String _wrongAuth =
      'Произошла ошибка, возможно неверный E-mail или пароль';
}

class _LoginFormModel {
  String email;
  String password;

  _LoginFormModel({
    required this.email,
    required this.password,
  });
}
