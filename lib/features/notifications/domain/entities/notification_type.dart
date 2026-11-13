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

  /// Para a anfitriã e a coordenação: alguém de fora do grupo pediu para
  /// participar de um encontro.
  meetingGuestRequested,

  /// Tipo criado no backend depois desta versão do app.
  unknown,
}
