abstract class TailRec<A> {
  A value;

  A result() {
    TailRec<A> tr = this;

    while (!(tr is _Done<A>)) {
      // this
      // Bounce
      if (tr is _Bounce<A>) {
        tr = (tr as _Bounce<A>).continuation();
        // Cont
      } else if (tr is Cont) {
        var a = (tr as Cont).a;
        TailRec<A> Function(A) f = (tr as Cont<A, A>).f;

        // a
        // Done
        if (a is _Done<A>) {
          tr = f(a.value);
          // Bounce
        } else if (a is _Bounce) {
          tr = ((a as _Bounce<A>).continuation().flatMap<A>(f));
          // Cont
        } else if (a is Cont) {
          TailRec<A> b = a.a as TailRec<A>;
          TailRec<A> Function(A) g = a.f as TailRec<A> Function(A);
          tr = b.flatMap<A>((x) => g(x).flatMap<A>(f));
        }
      }
    }
    return tr.value;
  }

/*
  A compute() {
    TailRec<A> res = this;

    while (!res._isDone) {
      _Bounce<A> r = res as _Bounce<A>;
      final _Bounce<A> bounce = r;
      res = bounce.continuation();
    }
    _Done<A> done = res as _Done<A>;
    return done.value;
  }
  

  bool get _isDone;
*/
  TailRec<B> map<B>(B Function(A) f) {
    return flatMap((a) => _Bounce(() => _Done<B>(f(a))));
  }

  TailRec<B> flatMap<B>(TailRec<B> Function(A) f);
}

class Cont<A, B> extends TailRec<B> {
  Cont(this.a, this.f);

  final TailRec<A> a;
  final TailRec<B> Function(A x) f;

  @override
  TailRec<C> flatMap<C>(TailRec<C> Function(B) f) =>
      Cont<A, C>(this.a, (A x) => this.f(x).flatMap(f));

  /*@override
  bool get _isDone => false;*/
}

class _Done<A> extends TailRec<A> {
  _Done(this.value);

  @override
  TailRec<B> flatMap<B>(TailRec<B> Function(A) f) =>
      _Bounce(() => f(this.value));

  @override
  final A value;

  /*@override
  final bool _isDone = true;*/
}

class _Bounce<A> extends TailRec<A> {
  _Bounce(this.continuation);

  TailRec<A> Function() continuation;

  @override
  TailRec<B> flatMap<B>(TailRec<B> Function(A) f) => Cont(this, f);

  /*@override
  final bool _isDone = false;*/
}

TailRec<A> done<A>(A x) => _Done<A>(x);

TailRec<A> tailcall<A>(TailRec<A> continuation()) => _Bounce<A>(continuation);

// -------------------------------------------------

class Defs {
  ///
  static TailRec<bool> odd(int n) =>
      n == 0 ? done(false) : tailcall(() => even(n - 1));
  static TailRec<bool> even(int n) =>
      n == 0 ? done(true) : tailcall(() => odd(n - 1));

  ///
  static bool badodd(int n) => n == 0 ? false : badeven(n - 1);
  static bool badeven(int n) => n == 0 ? true : badodd(n - 1);

  ///
  static TailRec<int> fib(int n) {
    if (n < 2) {
      return done<int>(n);
    } else {
      return tailcall<int>(() => fib(n - 1)).flatMap<int>((x) {
        return tailcall<int>(() => fib(n - 2)).map<int>((y) {
          return (x + y);
        });
      });
    }
  }
}

void main() {
  bool res1;
  int z = 12500;
  res1 = (Defs.even(z).result());

  print("Ergebnis von Odd/Even ist $res1");
  // res1 = (Defs.badeven(z)); // int z = 12500; geht noch.
  // print("Ergebnis von bad Odd/Even ist $res1");
  num res2;
  res2 = Defs.fib(14).result();
  print("Ergebnis von Fibonacci ist $res2");
}

/*

'Cont<List<Tupl<String, Termtype<String>>>, List<Tupl<String, Termtype<String>>>>' 
'_Done<List<Tupl<String, Termtype<String>>>>'


 */
