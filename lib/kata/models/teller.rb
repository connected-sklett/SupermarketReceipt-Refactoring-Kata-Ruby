class Kata::Teller
  def initialize(catalog)
    @catalog = catalog
    @offers = {}
  end

  def add_special_offer(offer_type, product, argument)
    @offers[product] = Kata::Offer.new(offer_type, product, argument)
  end

  def checks_out_articles_from(the_cart)
    receipt = Kata::Receipt.new
    items = the_cart.items
    for pq in items do
      product = pq.product
      quantity = pq.quantity
      unit_price = @catalog.unit_price(product)
      price = quantity * unit_price
      receipt.add_product(product, quantity, unit_price, price)
    end
    handle_offers(receipt, @offers, @catalog, the_cart)

    receipt
  end

  private
  
  def handle_offers(receipt, offers, catalog, the_cart)
    for product in the_cart.product_quantities.keys do
      Kata::DiscountCalculator.new(receipt, offers, catalog, product, the_cart.product_quantities).handle_offer
    end
  end
end
