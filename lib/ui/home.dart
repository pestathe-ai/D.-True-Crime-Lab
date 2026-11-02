import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/game.dart';
import '../story/model.dart';
import 'cards.dart';
import 'case_board.dart';
import 'gallery.dart';
import 'theme.dart';

/// Il dispositivo di Marta: cronologia, messaggi, galleria, indagine, rubrica.
class Home extends StatefulWidget {
  const Home({super.key, required this.game});

  final Game game;

  @override
  State<Home> createState() => _HomeState();
}

class _Tab {
  const _Tab(this.label, this.icon, this.filter);

  final String label;
  final IconData icon;
  final bool Function(Drop d) filter;
}

bool _isPrivateNote(Drop d) =>
    d.kind == DropKind.nota && d.title == 'Cartella privata';

final _tabs = <_Tab>[
  _Tab('Cronologia', Icons.history, (d) => true),
  _Tab(
    'Messaggi',
    Icons.chat_bubble_outline,
    (d) =>
        d.kind == DropKind.messaggio ||
        d.kind == DropKind.scelta ||
        d.kind == DropKind.vocale ||
        d.kind == DropKind.email,
  ),
  _Tab(
    'Galleria',
    Icons.photo_library_outlined,
    (d) => d.kind == DropKind.foto || _isPrivateNote(d),
  ),
  _Tab('Indagine', Icons.fingerprint, (d) => false),
  _Tab('Rubrica', Icons.contacts_outlined, (d) => d.kind == DropKind.contatto),
];

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int _index = 0;
  Timer? _timer;

  /// Contenuti appena visti in questa scheda: restano "NUOVO" finché
  /// non si cambia scheda.
  final Set<String> _fresh = {};

  Game get game => widget.game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => game.tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _markCurrent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) game.tick();
    if (state == AppLifecycleState.paused) game.voice.stop();
  }

  void _markCurrent() {
    if (!mounted) return;
    final f = _tabs[_index].filter;
    final ids = game.visible.where(f).where(game.isNew).map((d) => d.id);
    if (ids.isEmpty) return;
    _fresh.addAll(ids);
    game.markSeen(ids.toList());
  }

  @override
  Widget build(BuildContext context) {
    final visible = game.visible;
    final ending = game.ending;
    final status = game.paused
        ? 'In pausa'
        : ending != null
            ? 'Storia conclusa'
            : game.day == 0
                ? 'In attesa'
                : 'Giorno ${game.day} di 7';
    WidgetsBinding.instance.addPostFrameCallback((_) => _markCurrent());

    final Widget body;
    switch (_index) {
      case 2:
        body = Gallery(
          game: game,
          items: visible.where(_tabs[2].filter).toList(),
        );
      case 3:
        body = CaseBoard(game: game);
      case 4:
        body = _Contacts(
          game: game,
          items: visible.where(_tabs[4].filter).toList(),
        );
      default:
        body = _Feed(
          game: game,
          items: visible.where(_tabs[_index].filter).toList(),
          empty: _index == 1
              ? 'Ancora nessun messaggio.\nNessuno sa che hai questo '
                  'dispositivo. Per ora.'
              : 'Niente di nuovo.',
          showSignature: _index == 0,
          fresh: _fresh,
        );
    }

    final openQ = game.openQuestions.where((q) => !game.solved(q)).length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game.deviceName, style: sora(17, weight: 700)),
            Text(
              game.coop ? '◆ $status · in due' : '◆ $status',
              style: const TextStyle(fontSize: 12, color: Pal.accent),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Impostazioni',
            onPressed: () => _settings(context),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() {
            _fresh.clear();
            _index = i;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) => _markCurrent());
        },
        destinations: [
          for (var i = 0; i < _tabs.length; i++)
            NavigationDestination(
              icon: _badge(
                i == 3
                    ? openQ
                    : visible.where(_tabs[i].filter).where(game.isNew).length,
                Icon(_tabs[i].icon),
              ),
              label: _tabs[i].label,
            ),
        ],
      ),
    );
  }

  Widget _badge(int n, Widget child) {
    if (n == 0) return child;
    return Badge(
      label: Text('$n'),
      backgroundColor: Pal.accent,
      textColor: Pal.inkDark,
      child: child,
    );
  }

  void _settings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Pal.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => ListenableBuilder(
        listenable: game,
        builder: (ctx, _) {
          final s = game.state;
          if (s == null) return const SizedBox.shrink();
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Impostazioni', style: sora(18, weight: 700)),
                  const SizedBox(height: 8),
                  Text(
                    s.clock.preview
                        ? 'Modalità: anteprima veloce (3 minuti al giorno)'
                        : 'Modalità: tempo reale',
                    style: const TextStyle(color: Pal.muted),
                  ),
                  if (game.coop && s.caseCode != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Pal.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Pal.accent),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.onTablet
                                ? 'Partita a due · tu hai il TABLET'
                                : 'Partita a due · tu hai il TELEFONO',
                            style: sora(13, weight: 700, color: Pal.accent),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            s.caseCode!,
                            style: sora(22, weight: 800),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Il tuo amico lo inserisce in «Gioca in due → '
                            'Entra con un codice».',
                            style: TextStyle(color: Pal.muted, fontSize: 13),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: s.caseCode!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Codice copiato')),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copia codice'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notti tranquille'),
                    subtitle: const Text(
                      'Notifiche tra le 23 e le 8 spostate al mattino',
                      style: TextStyle(color: Pal.muted),
                    ),
                    value: s.quietNights,
                    onChanged: game.setQuietNights,
                  ),
                  if (!game.coop)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        game.paused ? Icons.play_arrow : Icons.pause,
                        color: Pal.accent,
                      ),
                      title: Text(
                        game.paused ? 'Riprendi la storia' : 'Metti in pausa',
                      ),
                      subtitle: const Text(
                        'In pausa il tempo della storia si ferma',
                        style: TextStyle(color: Pal.muted),
                      ),
                      onTap: game.togglePause,
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restart_alt, color: Pal.accent),
                    title: const Text('Ricomincia da capo'),
                    subtitle: const Text(
                      'Cancella le scelte e torna alla schermata iniziale',
                      style: TextStyle(color: Pal.muted),
                    ),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: ctx,
                        builder: (d) => AlertDialog(
                          backgroundColor: Pal.surface2,
                          title: const Text('Ricominciare?'),
                          content: const Text(
                            'Perderai le scelte e gli indizi raccolti.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(d, false),
                              child: const Text('Annulla'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(d, true),
                              child: const Text('Ricomincia'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && ctx.mounted) {
                        Navigator.pop(ctx);
                        await game.reset();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed({
    required this.game,
    required this.items,
    required this.empty,
    required this.showSignature,
    required this.fresh,
  });

  final Game game;
  final List<Drop> items;
  final String empty;
  final bool showSignature;
  final Set<String> fresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            empty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Pal.muted, height: 1.5),
          ),
        ),
      );
    }
    // I più recenti in alto, come in un vero telefono.
    final list = items.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: list.length + (showSignature ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == list.length) return const DomSignature();
        return DropCard(
          key: ValueKey(list[i].id),
          drop: list[i],
          game: game,
          highlight: fresh.contains(list[i].id),
        );
      },
    );
  }
}

class _Contacts extends StatelessWidget {
  const _Contacts({required this.game, required this.items});

  final Game game;
  final List<Drop> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (game.onTablet)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Dal tablet non si può telefonare: chiedi al tuo compagno, '
              'che ha il telefono.',
              style: TextStyle(color: Pal.accent, fontSize: 13),
            ),
          ),
        for (final c in items)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: c.callable ? Pal.accent : Pal.surface2,
              foregroundColor: c.callable ? Pal.inkDark : Pal.text,
              child: Text((c.title ?? '?').substring(0, 1)),
            ),
            title: Text(c.title ?? ''),
            subtitle: Text(c.body, style: const TextStyle(color: Pal.muted)),
            trailing: game.onTablet
                ? null
                : IconButton(
                    icon: const Icon(Icons.call, color: Pal.accent),
                    onPressed: () => _call(context, c),
                  ),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Le persone rispondono in modo diverso in base a cosa hai '
            'scoperto, e all\'ora della storia.',
            style: TextStyle(color: Pal.muted, fontSize: 12, height: 1.4),
          ),
        ),
        const DomSignature(),
      ],
    );
  }

  Future<void> _showCall(
    BuildContext context,
    String who,
    String text, {
    required bool answered,
    String? voice,
  }) async {
    if (answered && voice != null) {
      game.voice.play('call', text.replaceAll('\n', ' '), voice);
    }
    await showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: Pal.surface2,
        icon: Icon(
          answered ? Icons.phone_in_talk : Icons.phone_missed,
          color: Pal.accent,
        ),
        title: Text(who),
        content: Text(text, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () {
              game.voice.stop();
              Navigator.pop(d);
            },
            child: const Text('Riaggancia'),
          ),
        ],
      ),
    );
  }

  Future<void> _call(BuildContext context, Drop c) async {
    if (!c.callable) {
      final r = await game.call(c.id);
      if (!context.mounted) return;
      await _showCall(
        context,
        c.title ?? '',
        r.text,
        answered: r.answered,
        voice: r.voice,
      );
      return;
    }
    final storyOver = game.ending != null;
    if (!storyOver) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          backgroundColor: Pal.surface2,
          title: const Text('Chiamare Casa?'),
          content: const Text('Qualcuno ti ha chiesto di non farlo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Lascia stare'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Chiama'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    final r = await game.callCasa();
    if (!context.mounted) return;
    await _showCall(
      context,
      'Casa',
      r.text,
      answered: r.speaks,
      voice: r.speaks ? 'elsa' : null,
    );
  }
}
