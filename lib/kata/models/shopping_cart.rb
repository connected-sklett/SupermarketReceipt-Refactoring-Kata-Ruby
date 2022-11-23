class Kata::ShoppingCart

  

  def initialize
    @items = []
    @product_quantities = {}
  end

  def items
    Array.new @items
  end

  def add_item(product)
    add_item_quantity(product, 1.0)
    nil
  end

  def product_quantities
    @product_quantities
  end

  def add_item_quantity(product, quantity)
    @items << Kata::ProductQuantity.new(product, quantity)
    if @product_quantities.key?(product)
      product_quantities[product] = product_quantities[product] + quantity
    else
      product_quantities[product] = quantity
    end
  end

  def handle_offers(receipt, offers, catalog)
    for product in @product_quantities.keys do
      handle_offer(receipt, offers, catalog, product)
    end
  end

  private

  def handle_offer(receipt, offers, catalog, product)
    return unless offers.key?(product)
    
    quantity = @product_quantities[product]
    offer = offers[product]
    unit_price = catalog.unit_price(product)
    quantity_as_int = quantity.to_i
    discount = nil


    discount_quantity = discount_quantity(offer.offer_type)


    number_of_x = quantity_as_int / discount_quantity
    if offer.offer_type == Kata::SpecialOfferType::TWO_FOR_AMOUNT && quantity_as_int >= 2
      discount = two_for_amount(offer, quantity_as_int, discount_quantity, unit_price, quantity, product)
    end
    if offer.offer_type == Kata::SpecialOfferType::THREE_FOR_TWO && quantity_as_int > 2
      discount = three_for_two(quantity, unit_price, number_of_x, quantity_as_int, product)
    end
    if offer.offer_type == Kata::SpecialOfferType::TEN_PERCENT_DISCOUNT
      discount = ten_percent(product, offer, quantity, unit_price)
    end
    if offer.offer_type == Kata::SpecialOfferType::FIVE_FOR_AMOUNT && quantity_as_int >= 5
      discount = five_for_amount(unit_price, quantity, offer, number_of_x, quantity_as_int, product, discount_quantity)
    end


    receipt.add_discount(discount) if discount
  end

  def discount_quantity(offer_type)
    Hash.new(1).tap { |h|
          h[Kata::SpecialOfferType::TWO_FOR_AMOUNT] = 2
          h[Kata::SpecialOfferType::THREE_FOR_TWO] = 3
          h[Kata::SpecialOfferType::FIVE_FOR_AMOUNT] = 5
        }[offer_type]
  end

  def two_for_amount(offer, quantity_as_int, discount_quantity, unit_price, quantity, product)
    total = offer.argument * (quantity_as_int / discount_quantity) + quantity_as_int % 2 * unit_price
    discount_n = unit_price * quantity - total
    Kata::Discount.new(product, "2 for " + offer.argument.to_s, discount_n)
  end

  def three_for_two(quantity, unit_price, number_of_x, quantity_as_int, product)
    discount_amount = quantity * unit_price - ((number_of_x * 2 * unit_price) + quantity_as_int % 3 * unit_price)
    Kata::Discount.new(product, "3 for 2", discount_amount)
  end

  def ten_percent(product, offer, quantity, unit_price)
    Kata::Discount.new(product, offer.argument.to_s + "% off", quantity * unit_price * offer.argument / 100.0)
  end

  def five_for_amount(unit_price, quantity, offer, number_of_x, quantity_as_int, product, discount_quantity)
    discount_total = unit_price * quantity - (offer.argument * number_of_x + quantity_as_int % 5 * unit_price)
    Kata::Discount.new(product, discount_quantity.to_s + " for " + offer.argument.to_s, discount_total)
  end
end
