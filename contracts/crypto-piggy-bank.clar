;; Simple Token Transfer Contract
;; A basic fungible token implementation with transfer functionality

;; Define the token
(define-fungible-token simple-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))

;; Token name and symbol
(define-data-var token-name (string-ascii 32) "Simple Token")
(define-data-var token-symbol (string-ascii 10) "SIMPLE")
(define-data-var token-decimals uint u6)

;; Total supply tracking
(define-data-var total-supply uint u0)

;; Deposit tracking
(define-map deposits principal uint)
(define-data-var total-deposits uint u0)

;; Initialize the contract with initial supply
(define-public (initialize (initial-supply uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> initial-supply u0) err-invalid-amount)
    (try! (ft-mint? simple-token initial-supply tx-sender))
    (var-set total-supply initial-supply)
    (ok true)))

;; Transfer tokens between accounts
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
    (asserts! (> amount u0) err-invalid-amount)
    ;; Check for sufficient balance before transfer
    (asserts! (>= (ft-get-balance simple-token sender) amount) err-insufficient-balance)
    (try! (ft-transfer? simple-token amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)))

;; Get balance of an account
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance simple-token account)))

;; Get token info
(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

;; Mint new tokens (only owner)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (try! (ft-mint? simple-token amount recipient))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok true)))

;; Burn tokens
(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (or (is-eq tx-sender owner) (is-eq contract-caller owner)) err-not-token-owner)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= (ft-get-balance simple-token owner) amount) err-insufficient-balance)
    (try! (ft-burn? simple-token amount owner))
    (var-set total-supply (- (var-get total-supply) amount))
    (ok true)))

;; Get token URI (optional - for metadata)
(define-read-only (get-token-uri)
  (ok none))

;; SIP-010 trait compliance functions
(define-public (transfer-memo (amount uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin
    (try! (transfer amount sender recipient (some memo)))
    (ok true)))

;; Deposit STX function
(define-public (deposit (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set deposits tx-sender
             (+ (default-to u0 (map-get? deposits tx-sender)) amount))
    (var-set total-deposits (+ (var-get total-deposits) amount))
    (ok true)))

;; Get balance by sender - fixed return format
(define-read-only (get-balance-by-sender)
  (let ((balance (map-get? deposits tx-sender)))
    (ok (match balance
         amount (some {amount: amount})
         none))))

;; Get total deposits
