import Lean.Util.ShareCommon

open Lean.ShareCommon
def check (b : Bool) : ShareCommonT IO Unit := do
  unless b do throw $ IO.userError "check failed"

unsafe def tst1 : ShareCommonT IO Unit := do
let x := [1]
let y := [0].map (fun x => x + 1)
check $ ptrAddrUnsafe x != ptrAddrUnsafe y
let x ← shareCommonM x
let y ← shareCommonM y
check $ ptrAddrUnsafe x == ptrAddrUnsafe y
let z ← shareCommonM [2]
let x ← shareCommonM x
check $ ptrAddrUnsafe x == ptrAddrUnsafe y
check $ ptrAddrUnsafe x != ptrAddrUnsafe z
IO.println x
IO.println y
IO.println z

/--
info: [1]
[1]
[2]
-/
#guard_msgs in
#eval tst1.run

unsafe def tst2 : ShareCommonT IO Unit := do
let x := [1, 2]
let y := [0, 1].map (fun x => x + 1)
check $ ptrAddrUnsafe x != ptrAddrUnsafe y
let x ← shareCommonM x
let y ← shareCommonM y
check $ ptrAddrUnsafe x == ptrAddrUnsafe y
let z ← shareCommonM [2]
let x ← shareCommonM x
check $ ptrAddrUnsafe x == ptrAddrUnsafe y
check $ ptrAddrUnsafe x != ptrAddrUnsafe z
IO.println x
IO.println y
IO.println z

/--
info: [1, 2]
[1, 2]
[2]
-/
#guard_msgs in
#eval tst2.run

structure Foo :=
(x : Nat)
(y : Bool)
(z : Bool)

@[noinline] def mkFoo1 (x : Nat) (z : Bool) : Foo := { x := x, y := true, z := z }
@[noinline] def mkFoo2 (x : Nat) (z : Bool) : Foo := { x := x, y := true, z := z }

unsafe def tst3 : ShareCommonT IO Unit := do
let o1 := mkFoo1 10 true
let o2 := mkFoo2 10 true
let o3 := mkFoo2 10 false
check $ ptrAddrUnsafe o1 != ptrAddrUnsafe o2
check $ ptrAddrUnsafe o1 != ptrAddrUnsafe o3
let o1 ← shareCommonM o1
let o2 ← shareCommonM o2
let o3 ← shareCommonM o3
check $
  o1.x == 10 && o1.y == true &&
  o1.z == true && o3.z == false &&
  ptrAddrUnsafe o1 == ptrAddrUnsafe o2 &&
  ptrAddrUnsafe o1 != ptrAddrUnsafe o3
IO.println o1.x
pure ()

/-- info: 10 -/
#guard_msgs in
#eval tst3.run

unsafe def tst4 : ShareCommonT IO Unit := do
let x := ["hello"]
let y := ["ello"].map (fun x => "h" ++ x)
check $ ptrAddrUnsafe x != ptrAddrUnsafe y
let x ← shareCommonM x
let y ← shareCommonM y
check $ ptrAddrUnsafe x == ptrAddrUnsafe y
let z ← shareCommonM ["world"]
let x ← shareCommonM x
check $
  ptrAddrUnsafe x == ptrAddrUnsafe y &&
  ptrAddrUnsafe x != ptrAddrUnsafe z
IO.println x
IO.println y
IO.println z

/--
info: [hello]
[hello]
[world]
-/
#guard_msgs in
#eval tst4.run

@[noinline] def mkList1 (x : Nat) : List Nat := List.replicate x x
@[noinline] def mkList2 (x : Nat) : List Nat := List.replicate x x
@[noinline] def mkArray1 (x : Nat) : Array (List Nat) :=
#[ mkList1 x, mkList2 x, mkList2 (x+1) ]
@[noinline] def mkArray2 (x : Nat) : Array (List Nat) :=
mkArray1 x

unsafe def tst5 : ShareCommonT IO Unit := do
let a := mkArray1 3
let b := mkArray2 3
let c := mkArray2 4
IO.println a
IO.println b
IO.println c
check $
  ptrAddrUnsafe a != ptrAddrUnsafe b &&
  ptrAddrUnsafe a != ptrAddrUnsafe c &&
  ptrAddrUnsafe a[0]! != ptrAddrUnsafe a[1]! &&
  ptrAddrUnsafe a[0]! != ptrAddrUnsafe a[2]! &&
  ptrAddrUnsafe b[0]! != ptrAddrUnsafe b[1]! &&
  ptrAddrUnsafe c[0]! != ptrAddrUnsafe c[1]!
let a ← shareCommonM a
let b ← shareCommonM b
let c ← shareCommonM c
check $
  ptrAddrUnsafe a == ptrAddrUnsafe b &&
  ptrAddrUnsafe a != ptrAddrUnsafe c &&
  ptrAddrUnsafe a[0]! == ptrAddrUnsafe a[1]! &&
  ptrAddrUnsafe a[0]! != ptrAddrUnsafe a[2]! &&
  ptrAddrUnsafe b[0]! == ptrAddrUnsafe b[1]! &&
  ptrAddrUnsafe c[0]! == ptrAddrUnsafe c[1]!
pure ()

/--
info: #[[3, 3, 3], [3, 3, 3], [4, 4, 4, 4]]
#[[3, 3, 3], [3, 3, 3], [4, 4, 4, 4]]
#[[4, 4, 4, 4], [4, 4, 4, 4], [5, 5, 5, 5, 5]]
-/
#guard_msgs in
#eval tst5.run

@[noinline] def mkByteArray1 (x : Nat) : ByteArray :=
let r := ByteArray.empty
let r := r.push x.toUInt8
let r := r.push (x+(1:Nat)).toUInt8
let r := r.push (x+(2:Nat)).toUInt8
r

@[noinline] def mkByteArray2 (x : Nat) : ByteArray :=
mkByteArray1 x

unsafe def tst6 (x : Nat) : ShareCommonT IO Unit := do
let a := [mkByteArray1 x]
let b := [mkByteArray2 x]
let c := [mkByteArray2 (x+1)]
IO.println a
IO.println b
IO.println c
check $ ptrAddrUnsafe a != ptrAddrUnsafe b
check $ ptrAddrUnsafe a != ptrAddrUnsafe c
let a ← shareCommonM a
let b ← shareCommonM b
let c ← shareCommonM c
check $ ptrAddrUnsafe a == ptrAddrUnsafe b
check $ ptrAddrUnsafe a != ptrAddrUnsafe c
pure ()

/--
info: [[2, 3, 4]]
[[2, 3, 4]]
[[3, 4, 5]]
-/
#guard_msgs in
#eval (tst6 2).run


unsafe def tst7 (x : Nat) : ShareCommonT IO Unit := do
let o0 := mkByteArray2 x
let o1 ← shareCommonM o0
let o2 ← shareCommonM o1
let o3 ← shareCommonM o0
check $ ptrAddrUnsafe o1 == ptrAddrUnsafe o2
check $ ptrAddrUnsafe o1 == ptrAddrUnsafe o3

#eval (tst7 3).run
