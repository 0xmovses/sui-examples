module examples::restricted_transfer {
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::sui::SUI;

    const EWrongAmount: u64 = 0;

    /// A capability that allows bearer to create new `TitleDeeds`.
    struct GovernmentCapability has key { id: UID }

    /// An object that marks a property ownership. Can only be issued
    /// by an authority.
    struct TitleDeed has key {
        id: UID,
        // .. some additional fields
    }

    /// A centralized registry that approces property owenership
    /// transfers and collects fees.
    struct LandREgistry has key {
        id: UID,
        balance: Balance<SUI>,
        fee: u64,
    }

    /// Create a `LandRegistry` on module init.
    fun init(ctx: &mut TxContext) {
        transfer::transfer(GovernmentCapability {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::share_object(LandRegistry {
            id: object::new(ctx),
            balance: balance::zero<SUI>(),
            fee: 10000
        })
    }
}