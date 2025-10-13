# ☕🍫 Cocoa/Coffee Traceability & Premiums

> 🌱 Track agricultural lots from farm to buyer with automatic quality premium payments

## 📋 Overview

This smart contract enables transparent traceability of cocoa and coffee lots through the supply chain while automatically calculating and distributing quality premiums to farmers. Built on Stacks blockchain using Clarity.

## ✨ Key Features

- 👨‍🌾 **Farmer Registration**: Register farmers with location and certification status
- 🏢 **Buyer Verification**: Verified buyer system for trusted transactions  
- 📦 **Lot Creation**: Track individual crop lots with quality grades (1-5)
- 💰 **Automatic Premiums**: Quality-based pricing with built-in premium multipliers
- 🔍 **Full Traceability**: Complete transaction history for each lot
- ⭐ **Reputation System**: Farmer reputation scoring based on quality delivery

## 🎯 Quality Premium Structure

| Grade | Quality Level | Premium Multiplier |
|-------|---------------|-------------------|
| ⭐ 1  | Basic        | 120% of base price |
| ⭐⭐ 2 | Good         | 140% of base price |
| ⭐⭐⭐ 3 | Premium      | 160% of base price |
| ⭐⭐⭐⭐ 4 | Superior     | 200% of base price |
| ⭐⭐⭐⭐⭐ 5 | Exceptional  | 250% of base price |

## 🚀 Quick Start

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing

### Setup
```bash
clarinet new cocoa-coffee-project
cd cocoa-coffee-project
# Replace contracts/cocoa-coffee-project.clar with our contract
```

### Testing
```bash
clarinet check
clarinet test
```

## 📚 Usage Guide

### 1. Register as a Farmer 👨‍🌾
```clarity
(contract-call? .cocoa-coffee-traceability register-farmer 
  "John's Coffee Farm" 
  "Blue Mountains, Jamaica")
```

### 2. Register as a Buyer 🏢
```clarity
(contract-call? .cocoa-coffee-traceability register-buyer 
  "Premium Coffee Roasters")
```

### 3. Create a Lot 📦
```clarity
(contract-call? .cocoa-coffee-traceability create-lot
  "coffee"          ;; crop-type
  u1000            ;; quantity (kg)
  u4               ;; quality-grade (1-5)
  "Blue Mountains" ;; origin-location  
  u50)             ;; base-price (STX)
```

### 4. Purchase a Lot 💳
```clarity
(contract-call? .cocoa-coffee-traceability purchase-lot u1)
```

### 5. Verify Quality (Admin Only) ✅
```clarity
(contract-call? .cocoa-coffee-traceability verify-quality u1 true)
```

## 🔧 Admin Functions

### Certify Farmer
```clarity
(contract-call? .cocoa-coffee-traceability certify-farmer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Verify Buyer
```clarity
(contract-call? .cocoa-coffee-traceability verify-buyer 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
```

### Set Quality Premium
```clarity
(contract-call? .cocoa-coffee-traceability set-quality-premium u5 u300)
```

## 📊 Read-Only Functions

### Get Lot Information
```clarity
(contract-call? .cocoa-coffee-traceability get-lot-info u1)
```

### Check Farmer Details
```clarity
(contract-call? .cocoa-coffee-traceability get-farmer-info 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### View Transaction History
```clarity
(contract-call? .cocoa-coffee-traceability get-lot-history u1)
```

### Calculate Final Price
```clarity
(contract-call? .cocoa-coffee-traceability calculate-lot-price u1)
```

## 🎬 Example Workflow

1. **👨‍🌾 Farmer Registration**: Coffee farmer in Jamaica registers on platform
2. **📦 Lot Creation**: Creates lot with Grade 4 quality, 1000kg at 50 STX base price
3. **💰 Premium Calculation**: System calculates 200% premium = 100 STX total
4. **🏢 Buyer Purchase**: Verified roaster purchases lot, paying 100 STX to farmer
5. **🔍 Quality Verification**: Admin verifies quality matches Grade 4 standards
6. **⭐ Reputation Update**: Farmer's reputation score increases based on delivery

## 🛠️ Development

### Contract Structure
- **Data Maps**: Store farmers, buyers, lots, and transaction history
- **Quality System**: Built-in premium calculation based on grades 1-5
- **Access Control**: Owner-only functions for certification and verification
- **Payment Flow**: Automatic STX transfer from buyer to farmer

### Error Codes
- `u100`: Owner only operation
- `u101`: Entity not found  
- `u102`: Unauthorized access
- `u103`: Already exists
- `u104`: Insufficient funds
- `u105`: Invalid quality grade

## 🌍 Impact

- **🎯 Fair Pricing**: Farmers receive premiums for high-quality produce
- **🔗 Supply Chain Trust**: Immutable provenance records increase buyer confidence  
- **📈 Quality Incentives**: Reputation system encourages consistent quality
- **🌱 Sustainable Agriculture**: Better prices support sustainable farming practices

## 📄 License

MIT License - Build the future of agricultural supply chains! 🚀
