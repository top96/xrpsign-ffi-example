
import 'dart:convert';
import 'dart:ffi';

// Example of using structs to pass strings to and from Dart/C
class Utf8 extends Struct<Utf8> {
  @Uint8()
  int char;

  /// Allocates and stores the given Dart [String] as a [Pointer<Utf8>].
  static Pointer<Utf8> toUtf8(String str) {
    final ptr = Pointer<Utf8>.allocate(count: str.length + 1);
    final units = const Utf8Encoder().convert(str);
    units
        .asMap()
        .forEach((i, unit) => ptr.elementAt(i).load<Utf8>().char = unit);
    ptr.elementAt(units.length).load<Utf8>().char = 0;
    return ptr;
  }

  /// Gets the Dart [String] representation of a [Pointer<Utf8>].
  static String fromUtf8(Pointer<Utf8> ptr) {
    final units = <int>[];
    var len = 0;
    for (;;) {
      final char = ptr.elementAt(len++).load<Utf8>().char;
      if (char == 0) {
        break;
      }
      units.add(char);
    }
    return const Utf8Decoder().convert(units);
  }
}

typedef pt = Pointer<Utf8> Function(Pointer<Utf8> acct, Pointer<Utf8> dest,
    Pointer<Utf8> amt, Pointer<Utf8> s, Uint32 seq);
typedef PT = Pointer<Utf8> Function(Pointer<Utf8> acct, Pointer<Utf8> dest,
    Pointer<Utf8> amt, Pointer<Utf8> s, int seq);
main() {
  final dylib = DynamicLibrary.open('xrpsign.so');
  var acct = Utf8.toUtf8('r4AMrTbCSFx4yoxFffqUoZwo3JooFfMGkt');
  var dest = Utf8.toUtf8('rwAdVAPeZbfosa2D6Y19y9RCWuV7PL5fea');
  var s = Utf8.toUtf8('ss7t3Z6inhCy5YPuWejWFJYtC5bZk');
  var amt = Utf8.toUtf8('100/XRP');
  var seq = 1;
  final PT pay = dylib.lookup<NativeFunction<pt>>('Payment').asFunction();
  print(Utf8.fromUtf8(pay(acct,dest, amt, s, seq)));
}
