//: Playground - noun: a place where people can play

import UIKit
import Foundation

// 「A（Member）に変化が生じたら B（Boss）に伝えたい」とき
class Member {
    private let boss: Boss
    public var isFine: Bool = true {
        didSet(value) {
            boss.notify()
        }
    }

    public init(boss: Boss) {
        self.boss = boss
    }
}

class Boss {
    public func notify() {
        print("誰かから通知が来たよ")
    }
}

var boss1 = Boss()
var member1 = Member(boss: boss1)

member1.isFine = true

print("-----------------------------------------------------------")
// -----------------------------------------------------------
// 「通知元（A）の状態変化を、複数の通知先（B, C, D...）に伝えたい」とき
class A {
    private let b: B
    private let c: C
    private let d: D

    public var isFine: Bool = true {
        didSet(value) {
            if value {
                b.notifyByTwitter()
                c.notifyByTelephone()
                d.notifyByEmail()
            }
        }
    }
    public init(b: B, c: C, d: D) {
        self.b = b
        self.c = c
        self.d = d
    }
}

class B {
    func notifyByTwitter() { print("連絡がきた") }
}

class C {
    func notifyByTelephone() { print("連絡がきた") }
}

class D {
    func notifyByEmail() { print("連絡がきた") }
}

var b1 = B()
var c1 = C()
var d1 = D()
var a1 = A(b: b1, c: c1, d: d1)

a1.isFine = false

print("-----------------------------------------------------------")
// -----------------------------------------------------------

// pull型 Observer パターン:
// ObserverはObservableの状態が更新されたという事実を知ることができるが、どのような値に更新されたのかはObservableのプロパティなどを参照しにいかなければ知ることができない

public protocol Observable {
    func subscribe(obs: Observer)
    func unsubscribe(obs: Observer)
}

public protocol Observer: class {
    func notify()   // Point2: なんらかの変化が発生したという情報だけ受け取る
}

// 通知元
public class ConcreteObservable: Observable {
    private var observers: [Observer] = []   // Point1 通知先に通知するインスタンスを配列として保持
    public var isHoge: Bool = false {
        didSet(value) {
            observers.forEach { x in x.notify() }
        }
    }
    public func subscribe(obs: Observer) {
        observers.append(obs)
    }

    public func unsubscribe(obs: Observer) {
        observers = observers.filter { x in
            ObjectIdentifier(x) != ObjectIdentifier(obs)
        }
    }
}

// 通知先
public class ConcreteObserver: Observer {
    public func notify() { print("通知を受けた") }
}

let v1 = ConcreteObservable()
let obs1 = ConcreteObserver()
v1.subscribe(obs: obs1)
v1.isHoge = true
v1.unsubscribe(obs: obs1)
v1.isHoge = false

print("-----------------------------------------------------------")
// -----------------------------------------------------------

// push 型 Observer パターン: notify 時に更新後の値を渡してしまう構造にしたもの

