/// Module that defines a generic type `Guardian<T>` which can only be
/// instantiated with a witness.
module examples::guardian {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    /// Phantom paramter T can only by initialized in the `create_guardian`
    /// function. But the types passed her must have 'drop'.
    struct Guardian<phantom T: drop> has key, store {
        id: UID
    }

    /// The first arugment of this funciton is an actual insance of the 
    /// type T with `drop` ability. It is dropped as soon as received.
    /// It is received then nothing is done with it, therefore it is dropped.
    public fun create_guardian<T: drop>(
        _witness: T, ctx &mut TxContext
    ): Guardian<T> {
        Guardian { id: object::new(ctx) }
    }
}

/// Custom module that makes use of the `guardian`.
module examples::peace_guardian {
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // Use the `guardian` as a dependency.
    use 0x0::guardian;

    /// This type is inteded to be used only once.
    struct PEACE has drop {}

    /// Module initializer is the best way to ensure that the
    /// code is called only once. With `Witness` pattern it is
    /// often the best practice.
    fun init(ctx: &mut TxContext) {
        transfer::public_transfer(
            guardian::create_guardian(PEACE {}, ctx),
            tx_context::sender(ctx),
        )
    }
}