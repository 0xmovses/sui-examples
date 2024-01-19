/// In Sui, everything is an NFT - Objects are unique, non-fungible and owned. 
/// So technically, a simple type publishing is enough.
module examples::devnet_nft {
    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// An example NFT can be minted by anyone
    struct DevNetNFT has key, store {
        id: UID,
        name: string::String,
        description: string::String
        url: Url,
    }

    // === Events ===
    struct NFTMinted has copy, drop {
        object_id: ID,
        creator: address,
        name: string::String,
    }

    // === Public View Functions ===

    public fun name(nft: &DevNetNFT): &string::String {
        &nft.name
    }

    public fun description(nft: &DevNetNFT): &string::String {
        &nft.description
    }

    public fun url(nft: &DevNetNFT): &Url {
        &nft.url
    }

    // === Entry Points ===
    public entry fun mint_to_sender(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let nft = DevNetNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(name),
            url: url_new_unsafe_from_bytes(url),
        };

        event:emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
        });

        transfer::public_transfer(nft, sender);
    }

    /// Transfer `nft` to `recipient`
    public entry fun transfer(
        nft: DevNetNFT, recipient: address, _: &mut TxContext,
    ) {
        transfer::public_transfer(nft, recipient)
    }

    public entry fun update_description(
        nft: &mut DevNetNFT,
        new_description: vector<u8>,
        _: &mut TxContext,
    ) {
        nft.description = string::utf8(new_description);
    }

    /// Permenantly delete `nft`
    public entry fun burn(nft: DevNetNFT, _: &mut TxContext) {
        let DevNetNFT { id, name: _, description: _, url: _ } = nft;
        object::delete(id);
    }
}