/// Data e hora de parede de São Paulo para [date], lidas pelos campos
/// (`year`, `hour`...) do resultado; o instante do valor devolvido não é o
/// original.
///
/// O clube é de São Paulo e o backend agrupa os dias pelo fuso de lá; usar o
/// fuso do aparelho mostraria outro dia/hora para quem está fora dele. Sem
/// horário de verão desde 2019, São Paulo é UTC-3 fixo.
DateTime toSaoPaulo(DateTime date) =>
    date.toUtc().subtract(const Duration(hours: 3));

/// Dia civil de São Paulo em [date], à meia-noite local, comparável ao
/// `localDate` dos encontros.
DateTime saoPauloDayOf(DateTime date) {
  final saoPaulo = toSaoPaulo(date);
  return DateTime(saoPaulo.year, saoPaulo.month, saoPaulo.day);
}
