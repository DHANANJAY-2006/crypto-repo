Alright — I’ll take your **Simple Token Transfer Contract** as a reference and make a **Crypto Piggy Bank** Clarity project with **only two functions**.

Here’s the full thing with contract + README exactly in your requested format.

---

## **Clarity Contract — Crypto Piggy Bank**

```clarity
;; Crypto Piggy Bank
;; Users can lock their STX until a specific block height before withdrawing.

;; Store locked amounts with unlock block height
(define-map piggy-bank principal {amount: uint, unlock-block: uint})

;; Errors
(define-constant err-invalid-amount (err u100))
(define-constant err-not-unlocked (err u101))
(define-constant err-no-funds (err u102))

;; Function 1: Lock funds until a certain block height
(define-public (lock-funds (amount uint) (unlock-block uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> unlock-block block-height) err-invalid-amount)
    ;; Transfer STX from user to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    ;; Save lock info
    (map-set piggy-bank tx-sender {amount: amount, unlock-block: unlock-block})
    (ok true)
  )
)

;; Function 2: Withdraw funds after unlock block
(define-public (withdraw-funds)
  (let (
        (lock-info (map-get? piggy-bank tx-sender))
       )
    (match lock-info
      lock
        (begin
          (asserts! (>= block-height (get unlock-block lock)) err-not-unlocked)
          (asserts! (> (get amount lock) u0) err-no-funds)
          ;; Transfer STX back to user
          (try! (stx-transfer? (get amount lock) (as-contract tx-sender) tx-sender))
          ;; Remove from storage
          (map-delete piggy-bank tx-sender)
          (ok true)
        )
      (err err-no-funds)
    )
  )
)
```

---

## **README.md**

# **Crypto Piggy Bank**

## **1. Project Title**

Crypto Piggy Bank – A Simple STX Lock & Release Contract

## **2. Project Description**

The Crypto Piggy Bank is a Clarity smart contract that allows users to deposit STX tokens and lock them until a specified block height. Once the blockchain reaches that block height, users can withdraw their funds. This creates a simple savings mechanism on the Stacks blockchain without any third-party involvement.

## **3. Project Vision**

The vision of the Crypto Piggy Bank is to promote disciplined saving in the blockchain space by enabling users to lock funds for a fixed period. This ensures financial planning, prevents impulsive spending, and encourages holding strategies for crypto assets.

## **4. Future Scope**

* Add support for multiple deposits per user.
* Implement interest or rewards for locked funds.
* Allow deposits in fungible tokens, not just STX.
* Add penalty fees for early withdrawals.
* Integrate with DeFi lending platforms to utilize locked funds for yield.

## **5. Contract**

```clarity
(define-map piggy-bank principal {amount: uint, unlock-block: uint})

(define-constant err-invalid-amount (err u100))
(define-constant err-not-unlocked (err u101))
(define-constant err-no-funds (err u102))

(define-public (lock-funds (amount uint) (unlock-block uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> unlock-block block-height) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set piggy-bank tx-sender {amount: amount, unlock-block: unlock-block})
    (ok true)
  )
)

(define-public (withdraw-funds)
  (let (
        (lock-info (map-get? piggy-bank tx-sender))
       )
    (match lock-info
      lock
        (begin
          (asserts! (>= block-height (get unlock-block lock)) err-not-unlocked)
          (asserts! (> (get amount lock) u0) err-no-funds)
          (try! (stx-transfer? (get amount lock) (as-contract tx-sender) tx-sender))
          (map-delete piggy-bank tx-sender)
          (ok true)
        )
      (err err-no-funds)
    )
  )
)
```

---

If you want, I can also **upgrade this Piggy Bank to allow multiple deposits per user** so each deposit has its own unlock date — making it work more like a real-world recurring savings account. That would make it much more flexible.
