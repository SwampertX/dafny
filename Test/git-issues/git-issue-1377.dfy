// RUN: %exits-with 2 %dafny /compile:3 "%s" > "%t"
// RUN: %diff "%s.expect" "%t"

class Cell {
  var data: int
}

trait Trait {
  function method baz(): Cell
  function method xyz(): nat

  method M0(n: nat) returns (n': int)
  method M1(n: int) returns (n': nat)
  function method F0(n: nat): int
  function method F1(n: int): nat
  function method G(x: nat): nat
}

class Class extends Trait {
  constructor () {}
  // regression: the next two method declarations were once allowed
  function method baz(): Cell? { // error: baz() should not be allowed to widen the result type
    null
  }
  function method xyz(): int { // error: xyz() should not be allowed to widen the result type
    -4
  }

  function method baz'(c: Cell): Cell {
    c
  }
  function method xyz'(): nat {
    15
  }

  method M0(n: int) returns (n': nat) { n' := 0; } // error (x2): cannot change parameter types in override
  method M1(n: nat) returns (n': int) { n' := 0; } // error (x2): cannot change parameter types in override
  function method F0(n: int): nat { 0 } // error (x2): cannot change parameter/result types in override
  function method F1(n: nat): int { 0 } // error (x2): cannot change parameter/result types in override
  function method G(x: NatSym): NatSym
}

type NatSym = nat

method Problem(n: nat) {
  var e: Trait := new Class();

  if n == 0 {
    var z := e.baz().data;
  } else {
    var y := e.xyz() + 4;
    var z := 10 / y;
  }
}

method Main() {
  // if Class.baz() and Class.xyz() were allowed, then either of the following calls would cause a crash
  Problem(0);
  Problem(1);
}
