/// Pedido da leitora para participar de um encontro de grupo do qual não é
/// membro. Sem pedido, o campo da entidade é `null`.
enum CalendarGuestStatus {
  requested,
  accepted,
  rejected,

  /// Status criado no backend depois desta versão do app: o card não
  /// oferece ação, para não pedir de novo algo que a leitora já pediu.
  unknown,
}
