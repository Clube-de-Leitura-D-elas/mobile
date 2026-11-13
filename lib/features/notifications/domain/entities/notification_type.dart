enum NotificationType {
  birthday,
  bookSuggestionsReminder,
  coordinatorTasksReminder,
  hostTasksReminder,
  meetingReminder,
  meetingSchedulePending,
  meetingUpdated,
  drawResult,

  /// Para a coordenadora: alguém pediu entrada no grupo.
  groupJoinRequested,
  groupJoinApproved,

  /// A leitora continua fora do grupo: o destino é a tela pública dele.
  groupJoinRejected,

  /// Pedido de participação num encontro de outro grupo. A leitora não é
  /// membro: o destino é o calendário, não o detalhe do encontro.
  meetingGuestApproved,
  meetingGuestRejected,

  /// Tipo criado no backend depois desta versão do app.
  unknown,
}
