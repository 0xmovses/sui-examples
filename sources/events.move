module examples::donuts_with_events {
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    // This is the only dep you need for events.
    use sui::event;

    /// For when Coin balanceis too low.
    const ENotEnough: u64 = 0;

    /// Capabaliltiy that grants an onwer the right to collect profits.
    struct ShopOwnerCap has key { id: UID }

    /// A purchasable Donut. We ignore implementation.
    struct Donut has key { id: UID }

    struct DonutShop has key {
        id: UID,
        price: u64,
        balance: Balance<SUI>,
    }

    // ==== Events ====

    /// For when someone has purchased a donut.
    struct DonoutBought has copy, drop {
        id: ID,
    }

    // ==== Functions ====

    fun init(ctx: &mut TxContext) {
        transfer::transfer(ShowOwnerCap {
            id: object::new(ctx),
        }, tx_context::sender(ctx));
    
        transfer::share_object(DonutShop {
            id: object::new(ctx),
            price: 1000,
            balance: balance::zero(),
        })
    }

    public fun buy_donut(
        shop: &mut DonutShop, payment: &mut Coin<SUI>, ctx &mut TxContext
    ) {
        assert!(coin::value(payment) >= shop.price, ENotEnough);

        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, shop.price);
        let id = object::new(ctx);

        balance::join(&mut shop.balance, paid);

        //Emit the event
        event::emit(DonoutBought { id: object::uid_to_inner(&id) });
        transfer::transfer(Donut { id}, tx_context::sender(ctx))
    }

    /// Take coin from `DonutShop` and transfer it to tx sender.
    /// Requires auth from `ShopOwnerCap`.
    public fun collect_profits(
        _: &ShopOwnerCap, shop: &mut DonutShop, ctx: &mut TxContext
    ): Coin<SUI> {
        let amount = balance::value(&shop.balance);

        //create new ype instance and emit it
        event::emit(ProfitsCollected { amount });
        coin::take(&mut shop.balance, amount, ctx)
    }
}