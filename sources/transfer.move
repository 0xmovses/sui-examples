/// To make an object freely transferable, use a combination of key and store abilities.
/// A freely transferable Wrapper for custom data.
/// 
module examples::wrapper {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    /// An object with `store` can be transferred in any
    /// module without a custom transfer implementation.
    struct Wrapper<T: store> has key, store {
        id: UID,
        contents: T,
    }

    /// View function to read contents of a `Container`.
    public fun contents<T: store>(c: &Wrapper<T>): &T {
        &c.contents
    }

    /// Anyone can create a new object
    public fun create<T: store>(
        contents: T, ctx: &mut TxContext
    ): Wrapper<T> {
        Wrapper {
            contents,
            id: object::new(ctx),
        }
    }

    /// Destroy `Wrapper` and get T.
    public fun destroy<T: store> (c: Wrapper<T>): T {
        let Wrapper { id, contents } = c;
        object::delete(id);
        contents
    }
}

module examples::profile {
    use sui::url::{Self, Url};
    use std::string::{Self, String};
    use sui::tx_context::TxContext;

    // using Wrapper functionality 
    use examples::wrapper::{Self, Wrapper};

    /// Profile information, not an object, can be wrapped
    /// into a transferable container.
    struct ProfileInfo has store {
        name: String,
        url: Url,
    }

    /// Read `name` field `ProfileInfo`.
    public fun name(info: &ProfileInfo): &Url {
        &info.name
    }

    /// Read `url` field `ProfileInfo`.
    public fun url(info: &ProfileInfo): &Url {
        &info.url
    }

    /// Creates new `ProfileInfo` and wraps into `Wrapper`.
    /// Then transfers to sender. 
    public fun create_profile(
        name: vector<u8>, url: vector<u8>, ctx: *mut TxContext
    ): Wrapper<ProfileInfo> {
        // create a new container and wrap Profile Info into it
        let container = wrapper::create(ProfileInfo {
            name: string::utf8(name),
            url: url::new_unsafe_from_bytes(url),
        }, ctx);

        // `Wrapper` type is freely transferable
        container
    }
}