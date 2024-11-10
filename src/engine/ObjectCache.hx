package engine;

class ObjectCache<T> {
	var items:Array<Envelope<T>>;
	var max_items:Int;
	var create_item:Void->T;
	var on_cache_item:T->Void;

	public function new(max_items:Int, create_item:Void->T, on_cache_item:T->Void) {
		items = [];
		this.max_items = max_items;
		this.create_item = create_item;
		this.on_cache_item = on_cache_item;
	}

	public function get_item():T {
		// return existing item if one is available
		for (envelope in items) {
			if (!envelope.item_is_active) {
				envelope.item_is_active = true;
				return envelope.item;
			}
		}

		// return new item if the cache is not full
		if (items.length < max_items) {
			var item = create_item();
			items.push({
				item_is_active: true,
				item: item
			});
			return item;
		}

		#if debug
		trace('all items are in use');
		#end
		// return no item if the cache is full but no items are available
		return null;
	}

	/** performs the action on every active item, expire the item when the action returns true **/
	public function iterate_active(action:T->Bool) {
		for (envelope in items) {
			if (envelope.item_is_active) {
				if (action(envelope.item)) {
					#if debug
					trace('cached item');
					#end
					envelope.item_is_active = false;
					on_cache_item(envelope.item);
				}
			}
		}
	}

	/** performs the action on every item **/
	public function iterate_all(action:T->Void) {
		for (envelope in items) {
			action(envelope.item);
		}
	}
}

@:structInit
@:publicFields
class Envelope<T> {
	var item_is_active:Bool = false;
	var item:T;
}
