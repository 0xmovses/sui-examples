module examples::strings {
    use std::string::String;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    struct Name has key, store {
        id: UID,
        name: String
    }

    public fun mint_name(name: String, ctx: &mut TxContext): Name {
        Name { id: object::new(ctx), name}
    }
}