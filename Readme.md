
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
Contract address : STE4V1PZRX3NQ07KQW43FGMF1NK3NPJGDZ2QWCKZ.crypto-piggy-bank
<img width="1833" height="961" alt="image" src="https://github.com/user-attachments/assets/5d04337b-5afa-4fee-8adc-138af7cf6efc" />

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
