/// Relação da usuária com o grupo do encontro. Só [member] recebe nome do
/// local, endereço e anfitriã; para as demais o backend manda só o bairro.
enum CalendarMembershipStatus { member, requested, rejected, pending, none }
