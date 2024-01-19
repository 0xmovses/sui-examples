/// Read about Publishers and their use cases here https://examples.sui.io/basics/publisher.html
/// A simple package that defines an OTW and claims a `Publisher`
/// object for the sender.
module examples::owner {
    use sui::tx_context::TxContext;
    use sui::package;

    struct OWNER has drop {}

    /// Som other type to use in a dummy check
    struct ThisType {}

    /// After the module is published, the sender will receive
    /// a `Publisher` object which can be used to set Display,
    /// or manage the transfer policies in the `Kiosk` system.
    fun init(otw: OWNER, &mut TxContext) {
        package::claim_and_keep(otw, ctx)
    }
}

/// A module that utilizes the `Publisher` object to give a token
/// of appreciateion and a `TypeOwnerCap` for the owned type.
module examples::type_owner {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::package::{Self, Publisher};

    const ENotOwner: u64 = 0;

    /// A capability granted to those who want an "objective"
    /// confirmation of their ownership.
    
    struct TypeOwnerCap<phantom T> has key, store {
        id: UID,
    }

    public fun prove_ownership<T>(
        publisher: &Publisher, ctx: &mut TxContext
    ): TypeOwnerCap<T> {
        assert!(package::from_package<T>(publisher), ENotOwner);
        TypeOwnerCap<T> { id: object::new(ctx) }
    }
}