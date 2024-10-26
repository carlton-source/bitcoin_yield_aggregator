;; Bitcoin Yield Aggregator
;; A sophisticated yield optimization platform for BTC-based assets


;; Constants
(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-AMOUNT (err u1001))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1002))
(define-constant ERR-PROTOCOL-NOT-WHITELISTED (err u1003))
(define-constant ERR-STRATEGY-DISABLED (err u1004))
(define-constant ERR-MAX-DEPOSIT-REACHED (err u1005))
(define-constant ERR-MIN-DEPOSIT-NOT-MET (err u1006))
(define-constant PROTOCOL-ACTIVE true)
(define-constant PROTOCOL-INACTIVE false)

;; Data Variables
(define-data-var total-tvl uint u0)
(define-data-var platform-fee-rate uint u100) ;; 1% (base 10000)
(define-data-var min-deposit uint u100000) ;; Minimum deposit in sats
(define-data-var max-deposit uint u1000000000) ;; Maximum deposit in sats
(define-data-var emergency-shutdown boolean false)


;; Data Maps
(define-map user-deposits { user: principal } { amount: uint, last-deposit-block: uint })
(define-map user-rewards { user: principal } { pending: uint, claimed: uint })
(define-map protocols { protocol-id: uint } { name: (string-ascii 64), active: boolean, apy: uint })
(define-map strategy-allocations { protocol-id: uint } { allocation: uint }) ;; allocation in basis points (100 = 1%)
(define-map whitelisted-tokens { token: principal } { approved: boolean })


;; SIP-010 Token Interface
(define-trait sip-010-trait
    (
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))
        (get-balance (principal) (response uint uint))
        (get-decimals () (response uint uint))
        (get-name () (response (string-ascii 32) uint))
        (get-symbol () (response (string-ascii 32) uint))
        (get-total-supply () (response uint uint))
    )
)

;; Authorization Check
(define-private (is-contract-owner)
    (is-eq tx-sender contract-owner)
)