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

;; Protocol Management Functions
(define-public (add-protocol (protocol-id uint) (name (string-ascii 64)) (initial-apy uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (map-set protocols { protocol-id: protocol-id }
            { 
                name: name,
                active: PROTOCOL-ACTIVE,
                apy: initial-apy
            }
        )
        (map-set strategy-allocations { protocol-id: protocol-id } { allocation: u0 })
        (ok true)
    )
)

(define-public (update-protocol-status (protocol-id uint) (active boolean))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (map-set protocols { protocol-id: protocol-id }
            (merge (unwrap-panic (get-protocol protocol-id))
                { active: active }
            )
        )
        (ok true)
    )
)


(define-public (update-protocol-apy (protocol-id uint) (new-apy uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (map-set protocols { protocol-id: protocol-id }
            (merge (unwrap-panic (get-protocol protocol-id))
                { apy: new-apy }
            )
        )
        (ok true)
    )
)

;; Deposit Management
(define-public (deposit (token-trait <sip-010-trait>) (amount uint))
    (let
        (
            (user-principal tx-sender)
            (current-deposit (default-to { amount: u0, last-deposit-block: u0 } 
                (map-get? user-deposits { user: user-principal })))
        )
        (asserts! (not emergency-shutdown) ERR-STRATEGY-DISABLED)
        (asserts! (>= amount min-deposit) ERR-MIN-DEPOSIT-NOT-MET)
        (asserts! (<= (+ amount (get amount current-deposit)) max-deposit) ERR-MAX-DEPOSIT-REACHED)
        (asserts! (is-whitelisted token-trait) ERR-PROTOCOL-NOT-WHITELISTED)
        
        ;; Transfer tokens to contract
        (try! (contract-call? token-trait transfer 
            amount
            tx-sender
            (as-contract tx-sender)
            none))
        
        ;; Update user deposits
        (map-set user-deposits 
            { user: user-principal }
            { 
                amount: (+ amount (get amount current-deposit)),
                last-deposit-block: block-height
            })
        
        ;; Update TVL
        (var-set total-tvl (+ (var-get total-tvl) amount))
        
        ;; Rebalance protocols if needed
        (try! (rebalance-protocols))
        (ok true)
    )
)

(define-public (withdraw (token-trait <sip-010-trait>) (amount uint))
    (let
        (
            (user-principal tx-sender)
            (current-deposit (default-to { amount: u0, last-deposit-block: u0 }
                (map-get? user-deposits { user: user-principal })))
        )
        (asserts! (<= amount (get amount current-deposit)) ERR-INSUFFICIENT-BALANCE)
        
        ;; Update user deposits
        (map-set user-deposits
            { user: user-principal }
            {
                amount: (- (get amount current-deposit) amount),
                last-deposit-block: (get last-deposit-block current-deposit)
            })
        
        ;; Update TVL
        (var-set total-tvl (- (var-get total-tvl) amount))
        
        ;; Transfer tokens back to user
        (as-contract
            (try! (contract-call? token-trait transfer
                amount
                tx-sender
                user-principal
                none)))
        
        (ok true)
    )
)