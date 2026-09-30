import 'package:aevum/core/utils/time_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeUtils.formatSecondsSpoken', () {
    test('zero e valores negativos viram 0 segundos', () {
      expect(TimeUtils.formatSecondsSpoken(0), '0 segundos');
      expect(TimeUtils.formatSecondsSpoken(-5), '0 segundos');
    });

    test('usa singular e plural', () {
      expect(TimeUtils.formatSecondsSpoken(1), '1 segundo');
      expect(TimeUtils.formatSecondsSpoken(60), '1 minuto');
      expect(TimeUtils.formatSecondsSpoken(3600), '1 hora');
    });

    test('junta as partes com vírgula e "e"', () {
      expect(TimeUtils.formatSecondsSpoken(1499), '24 minutos e 59 segundos');
      expect(
        TimeUtils.formatSecondsSpoken(3725),
        '1 hora, 2 minutos e 5 segundos',
      );
      expect(TimeUtils.formatSecondsSpoken(7200), '2 horas');
    });

    test('formatWeekdays resume os dias de repetição', () {
      expect(TimeUtils.formatWeekdays({1, 2, 3, 4, 5, 6, 7}), 'Todos os dias');
      expect(TimeUtils.formatWeekdays({1, 2, 3, 4, 5}), 'Dias úteis');
      expect(TimeUtils.formatWeekdays({6, 7}), 'Fins de semana');
      expect(TimeUtils.formatWeekdays({5, 1, 3}), 'Seg, qua, sex');
    });
  });
}
