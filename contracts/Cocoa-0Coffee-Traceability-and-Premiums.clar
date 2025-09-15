(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-insufficient-funds (err u104))
(define-constant err-invalid-quality (err u105))

(define-data-var next-lot-id uint u1)

(define-map farmers principal {
  name: (string-ascii 50),
  location: (string-ascii 100),
  certified: bool,
  reputation-score: uint
})

(define-map buyers principal {
  name: (string-ascii 50),
  verified: bool,
  total-purchases: uint
})

(define-map lots uint {
  farmer: principal,
  crop-type: (string-ascii 20),
  quantity: uint,
  quality-grade: uint,
  origin-location: (string-ascii 100),
  harvest-date: uint,
  current-owner: principal,
  base-price: uint,
  premium-multiplier: uint,
  status: (string-ascii 20),
  created-at: uint
})

(define-map lot-history uint (list 10 {
  from: principal,
  to: principal,
  price: uint,
  timestamp: uint,
  quality-verified: bool
}))

(define-map quality-premiums uint uint)

(define-private (calculate-premium (quality-grade uint) (base-price uint))
  (let ((multiplier (default-to u100 (map-get? quality-premiums quality-grade))))
    (* base-price (/ multiplier u100))))

(define-private (is-authorized-party (lot-id uint) (caller principal))
  (match (map-get? lots lot-id)
    lot-data (or (is-eq caller (get farmer lot-data))
                 (is-eq caller (get current-owner lot-data))
                 (is-eq caller contract-owner))
    false))

(define-public (register-farmer (name (string-ascii 50)) (location (string-ascii 100)))
  (if (is-some (map-get? farmers tx-sender))
      err-already-exists
      (ok (map-set farmers tx-sender {
        name: name,
        location: location,
        certified: false,
        reputation-score: u50
      }))))

(define-public (register-buyer (name (string-ascii 50)))
  (if (is-some (map-get? buyers tx-sender))
      err-already-exists
      (ok (map-set buyers tx-sender {
        name: name,
        verified: false,
        total-purchases: u0
      }))))

(define-public (certify-farmer (farmer-addr principal))
  (if (is-eq tx-sender contract-owner)
      (match (map-get? farmers farmer-addr)
        farmer-data (ok (map-set farmers farmer-addr
                                (merge farmer-data { certified: true })))
        err-not-found)
      err-owner-only))

(define-public (verify-buyer (buyer-addr principal))
  (if (is-eq tx-sender contract-owner)
      (match (map-get? buyers buyer-addr)
        buyer-data (ok (map-set buyers buyer-addr
                               (merge buyer-data { verified: true })))
        err-not-found)
      err-owner-only))

(define-public (set-quality-premium (grade uint) (premium-percent uint))
  (if (is-eq tx-sender contract-owner)
      (if (and (>= grade u1) (<= grade u5) (>= premium-percent u50) (<= premium-percent u300))
          (ok (map-set quality-premiums grade premium-percent))
          err-invalid-quality)
      err-owner-only))

(define-public (create-lot 
  (crop-type (string-ascii 20))
  (quantity uint)
  (quality-grade uint)
  (origin-location (string-ascii 100))
  (base-price uint))
  (let ((lot-id (var-get next-lot-id))
        (current-block stacks-block-height))
    (if (and (is-some (map-get? farmers tx-sender))
             (>= quality-grade u1)
             (<= quality-grade u5)
             (> quantity u0)
             (> base-price u0))
        (begin
          (map-set lots lot-id {
            farmer: tx-sender,
            crop-type: crop-type,
            quantity: quantity,
            quality-grade: quality-grade,
            origin-location: origin-location,
            harvest-date: current-block,
            current-owner: tx-sender,
            base-price: base-price,
            premium-multiplier: (default-to u100 (map-get? quality-premiums quality-grade)),
            status: "available",
            created-at: current-block
          })
          (var-set next-lot-id (+ lot-id u1))
          (ok lot-id))
        err-unauthorized)))

(define-public (purchase-lot (lot-id uint))
  (match (map-get? lots lot-id)
    lot-data
    (let ((total-price (calculate-premium (get quality-grade lot-data) (get base-price lot-data)))
          (farmer-addr (get farmer lot-data))
          (current-block stacks-block-height))
      (if (and (is-some (map-get? buyers tx-sender))
               (is-eq (get status lot-data) "available")
               (not (is-eq tx-sender (get current-owner lot-data))))
          (match (stx-transfer? total-price tx-sender farmer-addr)
            success
            (let ((history-entry {
              from: (get current-owner lot-data),
              to: tx-sender,
              price: total-price,
              timestamp: current-block,
              quality-verified: false
            }))
              (map-set lots lot-id (merge lot-data {
                current-owner: tx-sender,
                status: "sold"
              }))
              (map-set lot-history lot-id 
                (default-to (list) (map-get? lot-history lot-id)))
              (match (map-get? buyers tx-sender)
                buyer-data
                (map-set buyers tx-sender
                  (merge buyer-data { 
                    total-purchases: (+ (get total-purchases buyer-data) u1)
                  }))
                true)
              (ok total-price))
            error
            err-insufficient-funds)
          err-unauthorized))
    err-not-found))

(define-public (verify-quality (lot-id uint) (verified bool))
  (if (and (is-eq tx-sender contract-owner) (is-some (map-get? lots lot-id)))
      (ok (map-set lot-history lot-id 
                   (default-to (list) (map-get? lot-history lot-id))))
      err-unauthorized))

(define-public (update-reputation (farmer-addr principal) (score uint))
  (if (is-eq tx-sender contract-owner)
      (match (map-get? farmers farmer-addr)
        farmer-data
        (if (<= score u100)
            (ok (map-set farmers farmer-addr
                        (merge farmer-data { reputation-score: score })))
            err-invalid-quality)
        err-not-found)
      err-owner-only))

(define-read-only (get-lot-info (lot-id uint))
  (map-get? lots lot-id))

(define-read-only (get-farmer-info (farmer-addr principal))
  (map-get? farmers farmer-addr))

(define-read-only (get-buyer-info (buyer-addr principal))
  (map-get? buyers buyer-addr))

(define-read-only (get-lot-history (lot-id uint))
  (map-get? lot-history lot-id))

(define-read-only (calculate-lot-price (lot-id uint))
  (match (map-get? lots lot-id)
    lot-data (some (calculate-premium (get quality-grade lot-data) (get base-price lot-data)))
    none))

(define-read-only (get-quality-premium (grade uint))
  (map-get? quality-premiums grade))

(map-set quality-premiums u1 u120)
(map-set quality-premiums u2 u140)
(map-set quality-premiums u3 u160)
(map-set quality-premiums u4 u200)
(map-set quality-premiums u5 u250)
