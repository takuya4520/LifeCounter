import 'package:objectbox/objectbox.dart';

@Entity()
class LifeEvent {
  LifeEvent({
    required this.count,
    required this.title,
  });
  int id = 0;
  String title;
  int count;
}
