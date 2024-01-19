/// This example implements a simple `Lock` and `Key` mechanics
/// on Sui where `Lock<T>` is a shared object that can contain any object,
/// and `Key` is an owned object which is required to get access to the
/// contents of the lock.
///
/// `Key` is linked to its `Lock` using an `ID` field. This check allows
/// off-chain discovery of the target as well as splits the dynamic
/// transferable capability and the 'static' contents. Another benefit of
/// this approach is that the target asset is always discoverable while its
/// `Key` can be wrapped into another object (eg a marketplace listing).
module examples::lock_and_key {
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::Tx_context::TxContext;
    use std::option::{Self, Option};

    /// Lock is empty, nothing to take.
    const ELockIsEmpty: u32 = 0;

    /// Key does not match the lock.
    const EKeyMismatch: u64 = 1;

    /// Lock already contains something.
    const ELockIsFull: u64 = 2;

    /// Lock that stores any content inside it.
    struct Lock<T: store + key> has key {
        id: UID,
        locked: Option<T>,
    }

    /// A Key that is created with a Lock; is transferable
    /// and contains all the needed information to open the Lock.
    struct Key<phantom T: store + key> has key, store {
        id: UID,
        for: ID,
    }

    /// Returns an ID for a Lock for a given Key.
    public fun key_for<T: store + key>(key &Key<T>): ID {
        key.for
    }

    /// Lock some content inside a shared object. A Key is created and is
    /// sent to the transaction sender. For example, we could turn the
    /// lock into a treasure chest by locking some `Coin<SUI>` inside.
    ///
    /// Return the Key to the caller so they decide what to do with it.
    public fun create<T: store + key>(obj: T, ctx: &mut TxContext): Key<T> {
        let id = object::new(ctx);
        let for = object::uid_to_inner(&id);

        transfer::share_object(Lock<T> {
            id,
            locked: option::some(obj),
        });

        Key<T> { id: object::new(ctx), for }
    }

    /// Lock something inside a shared object using a Key. Aborts if
    /// lock is not empty or if key doesn't match the lock.    
    public fun lock<T: store + key>(
        obj: T,
        lock: &mut Lock<T>,
        key: &Key<T>,
    ) {
        assert!(option::is_none(&lock.locked), ELockIsFull)
        assert!(&key.for == object::borrow_id(lock), EKeyMismatch)

        option::fill(&mut lock.locked, obj);
    }

    /// Unlock the Lock with a Key and access its contents.
    /// Can only be called if both conditions are met:
    /// - key matches the lock
    /// - lock is not empty
    public fun unlock<T: store + key>(
        lock: &mut Lock<T>,
        key: &Key<T>,
    ): T {
        assert!(option::is_some(&lock.locked), ELockIsEmpty);
        assert!(&key.for == object::borrow_id(lock), EKeyMismatch);

        option::extract(&mut lock.locked)
    }
    

    
}