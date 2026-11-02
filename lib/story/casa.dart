// Stagione 1: "Casa". Sette giorni, quattro finali.
// Tutti i nomi, i luoghi e i fatti sono inventati.
import 'model.dart';

const String choiceD3 = 'd3';
const String choiceD5 = 'd5';
const String keyCall = 'chiamata';

/// Valori possibili della chiave [keyCall].
const String callEarly = 'presto';
const String callHappy = 'felice';

bool _early(StoryAnswers a) => a.isAnswer(keyCall, callEarly);

/// Ramo finale scelto al giorno 5 (senza risposta conta come "niente").
String _d5(StoryAnswers a) => a[choiceD5] ?? 'niente';

final List<Drop> casaStory = [
  // ───────────────────────── GIORNO 0: già sul telefono
  const Drop(
    id: 's0',
    at: StoryTime(0),
    kind: DropKind.sistema,
    body: 'Questo telefono apparteneva a qualcun altro. Il suo account è '
        'ancora collegato: note, posta e messaggi continuano ad arrivare.\n'
        'Tu puoi solo guardare. O quasi.',
  ),
  const Drop(
    id: 'c_paolo',
    at: StoryTime(0),
    kind: DropKind.contatto,
    title: 'Paolo',
    body: 'Fratello · 347 •••• 112',
  ),
  const Drop(
    id: 'c_ettore',
    at: StoryTime(0),
    kind: DropKind.contatto,
    title: 'Ettore L.',
    body: 'Via dei Tigli 12 · fisso',
  ),
  const Drop(
    id: 'c_archivio',
    at: StoryTime(0),
    kind: DropKind.contatto,
    title: 'Archivio storico – Comune',
    body: 'Borgo Calce · ufficio',
  ),
  const Drop(
    id: 'n0',
    at: StoryTime(0),
    kind: DropKind.nota,
    from: 'Marta',
    body: 'Spesa: pane, batterie stilo, lampadina per la cantina.\n'
        'Chiamare Paolo per il compleanno di mamma.',
  ),
  const Drop(
    id: 'f0',
    at: StoryTime(0),
    kind: DropKind.foto,
    title: 'Borgo Calce, festa di settembre',
    body: 'Una piazza di paese al tramonto. Bandierine colorate tese tra i '
        'balconi, un palco ancora vuoto, una fila di sedie di plastica.',
  ),

  // ───────────────────────── GIORNO 1
  const Drop(
    id: '1a',
    at: StoryTime(1, 21, 47),
    kind: DropKind.promemoria,
    from: 'Marta',
    body: 'Riportare la chiave a E. Prima che arrivino le ruspe.\n'
        'Non dirlo a Paolo.',
    notif: 'Promemoria: riportare la chiave a E. …',
  ),
  const Drop(
    id: '1b',
    at: StoryTime(1, 23, 20),
    kind: DropKind.nota,
    from: 'Marta',
    body: 'Oggi in archivio ho cercato la pratica di via dei Tigli. '
        'Il 12 c\'è. Il 16 c\'è. Il 14 è come se qualcuno l\'avesse strappato '
        'via dal registro. Domani vado a vedere di persona.',
    notif: 'Nuova nota sincronizzata',
  ),

  // ───────────────────────── GIORNO 2
  const Drop(
    id: '2a',
    at: StoryTime(2, 8, 40),
    kind: DropKind.email,
    from: 'Archivio storico – Comune di Borgo Calce',
    title: 'Esito richiesta fascicolo n. 1989/14',
    body: 'Gentile dott.ssa Venier,\n\n'
        'la informiamo che il fascicolo da lei richiesto (catasto urbano, '
        'via dei Tigli 14, anno 1989) risulta ritirato per verifica '
        'd\'ufficio.\n\n'
        'Firma del ritiro: P. Venier, Ufficio Tecnico.\n\n'
        'Cordiali saluti,\nL\'Archivio',
    notif: 'Nuova email: Esito richiesta fascicolo n. 1989/14',
  ),
  const Drop(
    id: '2b',
    at: StoryTime(2, 13, 5),
    kind: DropKind.foto,
    title: 'Via dei Tigli',
    body: 'Un muro di mattoni chiari stretto fra due portoni. A sinistra il '
        'numero 12, a destra il 16. Nel mezzo nessun portone, nessun numero. '
        'Solo un vecchio campanello, murato a metà.',
    notif: 'Nuova foto nella galleria',
  ),
  const Drop(
    id: '2c',
    at: StoryTime(2, 19, 20),
    kind: DropKind.nota,
    from: 'Marta',
    body: 'Paolo dice che è un errore di numerazione, che nei paesi vecchi '
        'succede. Allora perché ha firmato lui il ritiro del fascicolo? '
        'E perché non mi guarda negli occhi quando ne parliamo?',
    notif: 'Nuova nota sincronizzata',
  ),

  // ───────────────────────── GIORNO 3
  const Drop(
    id: '3a',
    at: StoryTime(3, 8, 12),
    kind: DropKind.nota,
    from: 'Marta',
    body: 'Il civico 14 non esiste. Ho controllato tre volte.',
    notif: 'Nuova nota sincronizzata',
  ),
  const Drop(
    id: '3b',
    at: StoryTime(3, 11, 30),
    kind: DropKind.vocale,
    from: 'Ettore L.',
    title: 'Messaggio vocale · 0:09',
    voice: 'ettore',
    body: 'Marta, sono Ettore. La chiave tienila tu ancora un po\'. '
        'Lei sta bene, te lo giuro. Ma non venire più di giorno, '
        'che la gente guarda.',
    notif: 'Messaggio vocale da Ettore L.',
  ),
  const Drop(
    id: '3c',
    at: StoryTime(3, 17, 45),
    kind: DropKind.foto,
    title: 'Senza titolo',
    body: 'Una vecchia chiave di ottone, consumata dall\'uso. Legato '
        'all\'anello, un cartellino scritto a mano con inchiostro sbiadito: '
        '«14».',
    notif: 'Nuova foto nella galleria',
  ),
  const Drop(
    id: '3d',
    at: StoryTime(3, 22, 10),
    kind: DropKind.scelta,
    from: 'Numero sconosciuto',
    body: 'Ciao. Questo è il mio telefono, l\'ho perso qualche giorno fa in '
        'stazione. Vedo che è ancora acceso e che le notifiche vengono lette.\n'
        'Chi sei? Ti prego, non spegnerlo.',
    notif: 'Nuovo messaggio da un numero sconosciuto',
    deadline: StoryTime(4, 9, 0),
    options: [
      ChoiceOption(
        value: 'si',
        label: 'Ce l\'ho io. Te lo restituisco.',
        reply: 'Grazie. Davvero. Non posso venire a prenderlo adesso, è '
            'complicato. Tienilo acceso ancora qualche giorno. Ti spiegherò. '
            '— Marta',
      ),
      ChoiceOption(
        value: 'chi',
        label: 'Prima dimmi chi sei tu.',
        reply: 'Giusto. Mi chiamo Marta Venier, lavoro all\'archivio del '
            'comune di Borgo Calce. Su quel telefono c\'è una cosa che non ho '
            'fatto in tempo a salvare altrove. Tienilo acceso, per favore.',
      ),
      ChoiceOption(
        value: 'zitto',
        label: '(Non rispondere)',
      ),
    ],
  ),

  // ───────────────────────── GIORNO 4
  const Drop(
    id: '4a',
    at: StoryTime(4, 3, 12),
    kind: DropKind.vocale,
    from: 'Marta',
    title: 'Bozza vocale non inviata · 0:06',
    voice: 'marta',
    body: 'Se trovi questo telefono, non chiamare il numero salvato come Casa.',
    notif: 'Bozza vocale sincronizzata (0:06)',
  ),
  const Drop(
    id: 'casa',
    at: StoryTime(4, 3, 13),
    kind: DropKind.contatto,
    title: 'Casa',
    body: '0423 •••• 14 · fisso',
    notif: 'Nuovo contatto aggiunto: Casa',
    callable: true,
  ),
  Drop(
    id: '4c',
    at: const StoryTime(4, 9, 30),
    kind: DropKind.messaggio,
    from: 'Marta',
    body: 'Ho visto che è comparso il contatto Casa. Non chiamarlo, per nessun '
        'motivo.\nOra guarda nella galleria: c\'è una foto del 1989. Guardala '
        'bene, soprattutto il retro.',
    notif: 'Nuovo messaggio da Marta',
    when: (a) => a.isAnswer(choiceD3, 'si') || a.isAnswer(choiceD3, 'chi'),
  ),
  Drop(
    id: '4c2',
    at: const StoryTime(4, 9, 30),
    kind: DropKind.messaggio,
    from: 'Numero sconosciuto',
    body: 'Non rispondi, va bene. Ma so che stai leggendo.\nAllora leggi '
        'questo: non chiamare Casa. E guarda la foto del 1989 nella galleria.',
    notif: 'Nuovo messaggio da un numero sconosciuto',
    when: (a) => !(a.isAnswer(choiceD3, 'si') || a.isAnswer(choiceD3, 'chi')),
  ),
  const Drop(
    id: '4d',
    at: StoryTime(4, 9, 31),
    kind: DropKind.foto,
    title: '1989',
    body: 'Una foto ingiallita. Una donna sui sessant\'anni, cappotto scuro, '
        'davanti a un portone verde. Sopra il portone, chiarissimo, il '
        'numero 14.\nSul retro, a penna: «Elsa, l\'ultimo giorno.»',
    notif: 'Nuova foto nella galleria',
  ),
  const Drop(
    id: '4e',
    at: StoryTime(4, 20, 0),
    kind: DropKind.email,
    from: 'Ufficio Anagrafe – Borgo Calce',
    title: 'Re: ricerca anagrafica Venier Elsa',
    body: 'Gentile dott.ssa Venier,\n\n'
        'risulta registrato il decesso di Venier Elsa in data 3 marzo 1989, '
        'su dichiarazione del coniuge.\n\n'
        'Non risulta alcuna sepoltura nel cimitero comunale, né trasferimento '
        'ad altro comune.\n\n'
        'Per ulteriori verifiche può rivolgersi allo sportello.\n'
        'L\'Ufficio Anagrafe',
    notif: 'Nuova email: Re: ricerca anagrafica Venier Elsa',
  ),

  // ───────────────────────── GIORNO 5
  const Drop(
    id: '5a',
    at: StoryTime(5, 7, 55),
    kind: DropKind.nota,
    from: 'Marta',
    body: 'Nonna Elsa non è morta nel 1989. Il nonno lo ha dichiarato e nessuno '
        'ha mai controllato. Il nonno mentiva su tutto, la mamma lo diceva '
        'sempre.\nEttore sa. Ettore l\'ha sempre saputo.',
    notif: 'Nuova nota sincronizzata',
  ),
  const Drop(
    id: '5b',
    at: StoryTime(5, 12, 40),
    kind: DropKind.email,
    from: 'Paolo Venier',
    title: 'Smettila',
    body: 'Marta,\n\nho saputo che sei tornata in archivio. Smettila.\n\n'
        'Fra due giorni la ditta Ferrante abbatte il blocco tra il 12 e il 16. '
        'È tutto approvato, i permessi ci sono, e se salta tutto salta anche '
        'il mio posto.\n\nLascia stare il passato. Lì dentro non c\'è niente.\n'
        'P.',
    notif: 'Nuova email da Paolo Venier: Smettila',
  ),
  const Drop(
    id: '5c',
    at: StoryTime(5, 18, 29),
    kind: DropKind.email,
    from: 'Marta Venier (bozza)',
    title: 'Fascicolo 1989/14 – copia',
    body: 'Copia digitale del fascicolo catastale di via dei Tigli 14.\n\n'
        'Pagina 1: abitazione su due piani. Proprietaria: Venier Elsa.\n'
        'Pagina 2: annotazione a matita, 1989: «Immobile non più censito. '
        'Accesso murato su richiesta del coniuge.»\n'
        'Pagina 3: timbro dell\'Ufficio Tecnico, firma illeggibile.',
  ),
  const Drop(
    id: '5d',
    at: StoryTime(5, 18, 30),
    kind: DropKind.scelta,
    from: 'Marta',
    body: 'Hai letto l\'email di Paolo? Vogliono abbattere il muro fra due '
        'giorni. Se lì dietro c\'è qualcuno…\n\n'
        'Ascolta: nella posta di questo telefono c\'è ancora la copia del '
        'fascicolo 1989/14, quella che Paolo crede di aver fatto sparire. '
        'Se la mando io al giornale, la ditta capisce subito chi è stato. '
        'Se la mandi tu, da un telefono che nessuno controlla, forse abbiamo '
        'una possibilità.\n\nMi aiuti?',
    notif: 'Nuovo messaggio da Marta: «Mi aiuti?»',
    deadline: StoryTime(6, 10, 0),
    options: [
      ChoiceOption(
        value: 'giornale',
        label: 'La mando io alla Gazzetta.',
        reply: 'Grazie. Fallo stasera. Io intanto vado da Ettore.',
      ),
      ChoiceOption(
        value: 'paolo',
        label: 'Scrivo io a Paolo. È tuo fratello.',
        reply: 'Paolo? Non lo so… Forse hai ragione, forse lui davvero non sa '
            'niente. Va bene. Il suo numero è in rubrica. Io non ce la faccio.',
      ),
      ChoiceOption(
        value: 'niente',
        label: 'Mi dispiace, non voglio immischiarmi.',
        reply: 'Capisco. Non è la tua storia. Ci provo da sola.',
      ),
    ],
  ),

  // ───────────────────────── GIORNO 6
  Drop(
    id: '6e',
    at: const StoryTime(6, 10, 0),
    kind: DropKind.messaggio,
    from: 'Marta',
    body: 'Hai chiamato Casa, vero?\nEttore dice che quel telefono ha squillato '
        'dopo trentasette anni di silenzio. Da allora lei non risponde più a '
        'nessuno.',
    notif: 'Nuovo messaggio da Marta',
    when: _early,
  ),
  Drop(
    id: '6g',
    at: const StoryTime(6, 10, 15),
    kind: DropKind.email,
    from: 'Redazione – Gazzetta di Borgo Calce',
    title: 'Re: via dei Tigli 14',
    body: 'Buongiorno,\n\nabbiamo ricevuto il materiale. Abbiamo verificato con '
        'l\'anagrafe e con un vicino, il signor Ettore L.\n\n'
        'Domattina all\'alba saremo in via dei Tigli con un fotografo, prima '
        'delle ruspe.\n\nGrazie per la segnalazione.\nLa Redazione',
    notif: 'Nuova email: Re: via dei Tigli 14',
    when: (a) => _d5(a) == 'giornale',
  ),
  Drop(
    id: '6p',
    at: const StoryTime(6, 10, 15),
    kind: DropKind.messaggio,
    from: 'Paolo',
    body: 'Ho ricevuto il tuo messaggio. Non so chi sei né come hai il telefono '
        'di mia sorella.\nMa ho riletto il fascicolo. Quella grafia a matita è '
        'di mio nonno.\nStanotte vado a vedere quel muro. Da solo.',
    notif: 'Nuovo messaggio da Paolo',
    when: (a) => _d5(a) == 'paolo',
  ),
  Drop(
    id: '6n',
    at: const StoryTime(6, 10, 15),
    kind: DropKind.nota,
    from: 'Marta',
    body: 'Sono andata da Ettore. Non mi ha aperto. Dalla finestra mi ha fatto '
        'solo segno di andare via.\nDomani arrivano le ruspe e io non so più '
        'cosa fare.',
    notif: 'Nuova nota sincronizzata',
    when: (a) => _d5(a) == 'niente',
  ),
  const Drop(
    id: '6z',
    at: StoryTime(6, 23, 58),
    kind: DropKind.vocale,
    from: 'Ettore L.',
    title: 'Messaggio vocale · 0:11',
    voice: 'ettore',
    body: 'Marta… stanotte lei ha preparato la valigia piccola. Quella del '
        '1989. Dice che sente già il rumore delle ruspe. Io le ho detto di '
        'aspettare. Speriamo.',
    notif: 'Messaggio vocale da Ettore L.',
  ),

  // ───────────────────────── GIORNO 7 · Finale "La tazza tiepida"
  Drop(
    id: '7e1',
    at: const StoryTime(7, 6, 30),
    kind: DropKind.nota,
    from: 'Marta',
    body: 'Hanno abbattuto il muro alle sei. Dietro c\'era una cucina in '
        'ordine, una radio, una tazza ancora tiepida sul tavolo. Nessuno.\n'
        'Accanto alla tazza, un biglietto: «Qualcuno ha chiamato. Vado.»',
    notif: 'Nuova nota sincronizzata',
    when: _early,
  ),
  Drop(
    id: '7e2',
    at: const StoryTime(7, 9, 0),
    kind: DropKind.email,
    from: 'Marta Venier',
    title: 'Perché non dovevi chiamare',
    body: 'La linea di Casa non arrivava solo lì. Da mesi la ditta Ferrante '
        'l\'aveva fatta deviare anche sul telefono del cantiere, per capire se '
        'l\'edificio era davvero vuoto.\n\nQuella chiamata gli ha detto che '
        'non lo era. Lei l\'ha capito prima di loro.\n\nSpero solo che adesso '
        'sia lontana, e al sicuro.\nM.',
    notif: 'Nuova email da Marta Venier',
    when: _early,
  ),
  Drop(
    id: '7e3',
    at: const StoryTime(7, 9, 1),
    kind: DropKind.sistema,
    body: 'La storia è finita.',
    ending: 'Finale 4 di 4 · La tazza tiepida',
    when: _early,
  ),

  // ───────────────────────── GIORNO 7 · Finale "La finestra aperta"
  Drop(
    id: '7g1',
    at: const StoryTime(7, 6, 30),
    kind: DropKind.foto,
    title: 'Gazzetta di Borgo Calce',
    body: 'Prima pagina, edizione straordinaria. Titolo: «Via dei Tigli, il '
        'civico che non c\'era». In foto il muro ancora in piedi e, davanti, '
        'una ruspa ferma con il motore spento.',
    notif: 'Nuova foto nella galleria',
    when: (a) => !_early(a) && _d5(a) == 'giornale',
  ),
  Drop(
    id: '7g2',
    at: const StoryTime(7, 7, 10),
    kind: DropKind.vocale,
    from: 'Casa',
    title: 'Messaggio vocale · 0:21',
    voice: 'elsa',
    body: 'Ciao. Non so come ti chiami. Marta mi ha detto che sei stato tu. '
        'Per trentasette anni ho vissuto dietro un muro, perché avevo paura di '
        'un uomo che è morto da tanto tempo. Stamattina ho aperto la finestra. '
        'Grazie.',
    notif: 'Messaggio vocale da: Casa',
    when: (a) => !_early(a) && _d5(a) == 'giornale',
  ),
  Drop(
    id: '7g3',
    at: const StoryTime(7, 7, 30),
    kind: DropKind.messaggio,
    from: 'Marta',
    body: 'Adesso puoi chiamare Casa. Davvero. Qualcuno ti risponderà.',
    notif: 'Nuovo messaggio da Marta',
    when: (a) => !_early(a) && _d5(a) == 'giornale',
  ),
  Drop(
    id: '7g4',
    at: const StoryTime(7, 7, 31),
    kind: DropKind.sistema,
    body: 'La storia è finita. Prova a chiamare Casa dalla Rubrica.',
    ending: 'Finale 1 di 4 · La finestra aperta',
    when: (a) => !_early(a) && _d5(a) == 'giornale',
  ),

  // ───────────────────────── GIORNO 7 · Finale "Il fratello"
  Drop(
    id: '7p1',
    at: const StoryTime(7, 6, 30),
    kind: DropKind.email,
    from: 'Paolo Venier',
    title: 'Scusa',
    body: 'Marta,\n\nho fermato la ditta. Ho strappato il permesso davanti al '
        'geometra.\n\nStanotte sono entrato con Ettore. Lei era lì, seduta in '
        'cucina, come se ci aspettasse.\n\nNon lo sapevo. Te lo giuro che non '
        'lo sapevo. Il nonno ci aveva detto che era morta.\n\n'
        'Vieni. Ti aspettiamo.\nPaolo',
    notif: 'Nuova email da Paolo Venier: Scusa',
    when: (a) => !_early(a) && _d5(a) == 'paolo',
  ),
  Drop(
    id: '7p2',
    at: const StoryTime(7, 7, 10),
    kind: DropKind.vocale,
    from: 'Casa',
    title: 'Messaggio vocale · 0:12',
    voice: 'elsa',
    body: 'Paolo è venuto stanotte. Ha pianto come quando aveva sei anni e si '
        'era perso alla fiera. Chiunque tu sia, grazie per avergli scritto.',
    notif: 'Messaggio vocale da: Casa',
    when: (a) => !_early(a) && _d5(a) == 'paolo',
  ),
  Drop(
    id: '7p3',
    at: const StoryTime(7, 7, 11),
    kind: DropKind.sistema,
    body: 'La storia è finita.',
    ending: 'Finale 2 di 4 · Il fratello',
    when: (a) => !_early(a) && _d5(a) == 'paolo',
  ),

  // ───────────────────────── GIORNO 7 · Finale "Il silenzio"
  Drop(
    id: '7n1',
    at: const StoryTime(7, 6, 30),
    kind: DropKind.nota,
    from: 'Marta',
    body: 'Le ruspe sono arrivate alle sei e si sono fermate alle sei e dieci. '
        'Ettore si è seduto davanti al muro su una sedia da cucina e non si è '
        'più alzato. Il cantiere è sospeso.\nMa dietro il muro nessuno '
        'risponde più.',
    notif: 'Nuova nota sincronizzata',
    when: (a) => !_early(a) && _d5(a) == 'niente',
  ),
  Drop(
    id: '7n2',
    at: const StoryTime(7, 8, 0),
    kind: DropKind.messaggio,
    from: 'Marta',
    body: 'Grazie comunque per aver tenuto acceso il telefono. Forse un giorno '
        'saprò cosa c\'era lì dietro.',
    notif: 'Nuovo messaggio da Marta',
    when: (a) => !_early(a) && _d5(a) == 'niente',
  ),
  Drop(
    id: '7n3',
    at: const StoryTime(7, 8, 1),
    kind: DropKind.sistema,
    body: 'La storia è finita.',
    ending: 'Finale 3 di 4 · Il silenzio',
    when: (a) => !_early(a) && _d5(a) == 'niente',
  ),
];

/// Cosa succede quando si chiama Casa, a seconda del momento.
const String callEarlyText = 'Squilla. Una, due, tre volte.\n'
    'Qualcuno solleva la cornetta. Lo senti respirare.\n'
    'Poi riattacca.';

const String callHappyText = 'Pronto?… Sì. Sono io.\nSono a casa.';

const String callDeadText = 'Il numero da lei chiamato non è più attivo.';
