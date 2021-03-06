tailcalls
=========

A library for trampolining tail calls.

# Example 1:


```dart
import 'package:tailcalls/tailcalls.dart';

TailRec<int> fib(int n) {
  if (n < 2) {
    return done(n);
  } else {
    return tailcall(() => fib(n - 1)).flatMap((x) {
      return tailcall(() => fib(n - 2)).map((y) {
        return (x + y);
      });
    });
  }
}

void main() {
  var res = fib(20).result();
  print("Result: $res");
}

```

# Example 2:


```
TailRec<bool> isEven(List<int> xs) {
  if (xs.isEmpty) {
    return done(true);
  } else {
    return tailcall(() => isOdd(xs.sublist(1)));
  }
}

TailRec<bool> isOdd(List<int> xs) {
  if (xs.isEmpty) {
    return done(false);
  } else {
    return tailcall(() => isEven(xs.sublist(1)));
  }
}

void main() {
  List<int> r = rangeList(1, 40002);
  print(r.last);
  bool res = isEven(r).result();
  print(res);
}

```


[Read more](https://en.wikipedia.org/wiki/Trampoline_(computing))
about trampoling in computing on Wikipedia.










# tailcall
