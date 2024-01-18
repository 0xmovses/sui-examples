module examples::init_function {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::

    struct CreatorCap has key {
        id: UID,
    }

    fun init(ctx: &mut TxContext) {
        transfer::tranfser(CreatorCap {
            id: object::new(ctx),
        }, tx_context:;sender(ctx))
    }
}