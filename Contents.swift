//: Playground - noun: a place where people can play

import UIKit
import Foundation

// Part1: 「A（Member）に変化が生じたら B（Boss）に伝えたい」とき
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

// Part2: 「通知元（A）の状態変化を、複数の通知先（B, C, D...）に伝えたい」とき
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

// Part3: pull型Observerパターン:
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
v1.isHoge = true    //=> ログ出力される
v1.unsubscribe(obs: obs1)
v1.isHoge = false   //=> ログ出力されない

print("-----------------------------------------------------------")
// -----------------------------------------------------------

// Part4: push型Observerパターン: notify時に更新後の値を渡してしまう構造
public protocol ObserverType: class {
    associatedtype E
    func notify(value: E)
}

public protocol ObservableType {
    associatedtype E
    func subscribe<O: ObserverType>(obs: O) where O.E == E
    func unsubscribe<O: ObserverType>(obs: O) where O.E == E
}

// abstractクラス: abstractクラスとは、抽象(Protocolのようなもの)メソッドを1つ以上持つクラス
public class PushObservable<Element>: ObservableType {
    public typealias E = Element
    public func subscribe<O>(obs: O) where O : ObserverType, Element == O.E {
        fatalError("not implemented")
    }
    public func unsubscribe<O>(obs: O) where O : ObserverType, Element == O.E {
        fatalError("not implemented")
    }
}

public class BooleanObservable: PushObservable<Bool> {
    private var observers: [ObjectIdentifier:AnonymousObserver<Bool>] = [:]
    public var isHoge: Bool = false {
        didSet(value) {
            observers.forEach { x in
                x.value.notify(value: isHoge)   // 通知時に更新後の値を渡す
            }
        }
    }
    public override func subscribe<O>(obs: O) where O: ObserverType, O.E == Bool {
        observers[ObjectIdentifier(obs)] = AnonymousObserver(handler: obs.notify)
    }
    public override func unsubscribe<O>(obs: O) where O : ObserverType, O.E == Bool {
        observers[ObjectIdentifier(obs)] = nil
    }
}

public class AnonymousObserver<Element>: ObserverType {
    public typealias E = Element
    public typealias Handler = (E) -> Void
    private let handler: Handler

    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    public func notify(value: Element) {
        handler(value)
    }
}

var observable = BooleanObservable()
var observer = AnonymousObserver<Bool>(handler: { x in print("\(String(x))") })

observable.isHoge = false   //=> ログ出力されない
observable.subscribe(obs: observer)
observable.isHoge = true    //=> ログ出力される
observable.unsubscribe(obs: observer)
observable.isHoge = false   //=> ログ出力されない


