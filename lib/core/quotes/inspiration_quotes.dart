class InspirationQuotes {
  static const List<String> focusAffirmations = [
    'Você está no controle do seu tempo.',
    'Cada minuto de foco constrói o seu futuro.',
    'Respire fundo e mantenha o ritmo suave.',
    'A consistência supera a intensidade passageira.',
    'Este momento é seu. Desfrute do processo.',
    'Grandes obras são feitas de pequenos blocos de foco.',
    'Sua mente é capaz de realizações incríveis.',
    'Silencie o ruído, abrace a presença.',
    'Um passo de cada vez, sem pressa e sem pausa.',
    'A clareza vem com a ação concentrada.',
  ];

  static const List<String> writingAffirmations = [
    'As palavras certas fluem quando você se permite começar.',
    'Não edite enquanto escreve. Apenas deixe o fluxo acontecer.',
    'Escrever 15 minutos hoje é plantar uma história para o amanhã.',
    'Sua voz é única e merece ser ouvida.',
    'O primeiro rascunho serve apenas para colocar as ideias na página.',
  ];

  static const List<String> meditationAffirmations = [
    'Apenas observe a respiração entrar e sair.',
    'Não lute contra os pensamentos, deixe-os passar como nuvens.',
    'Paz não é ausência de ruído, é serenidade interior.',
    'Você está exatamente onde precisa estar agora.',
    'Sinta o corpo relaxar a cada ciclo de ar.',
  ];

  static const List<String> completionPraise = [
    'Excelente trabalho! Mais um bloco de foco concluído.',
    'Você manteve seu compromisso consigo mesmo hoje! 🎉',
    'Sensação incrível de dever cumprido! Continue assim.',
    'Sua consistência está cada dia mais forte!',
    'Parabéns pelo foco e dedicação.',
  ];

  static String getRandomAffirmation({String? taskTitle}) {
    final titleLower = (taskTitle ?? '').toLowerCase();
    if (titleLower.contains('escr') || titleLower.contains('text') || titleLower.contains('livro')) {
      final combined = [...focusAffirmations, ...writingAffirmations];
      combined.shuffle();
      return combined.first;
    }
    if (titleLower.contains('medit') || titleLower.contains('resp') || titleLower.contains('zen') || titleLower.contains('calm')) {
      final combined = [...focusAffirmations, ...meditationAffirmations];
      combined.shuffle();
      return combined.first;
    }
    final list = [...focusAffirmations];
    list.shuffle();
    return list.first;
  }

  static String getRandomCompletionPraise() {
    final list = [...completionPraise];
    list.shuffle();
    return list.first;
  }
}
