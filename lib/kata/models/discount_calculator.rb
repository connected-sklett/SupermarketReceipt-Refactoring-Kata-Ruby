class Kata::DiscountCalculator
    attr_reader :receipt, :offers, :catalog, :product, :product_quantities

    def initialize(receipt, offers, catalog, product, product_quantities)
        @receipt = receipt
        @offers = offers
        @catalog = catalog
        @product = product
        @product_quantities = product_quantities
    end

    def handle_offer()
        return unless offers.key?(product)
        
        offer = offers[product]
        unit_price = catalog.unit_price(product)
        quantity_as_int = quantity.to_i
        discount = nil
        discount_quantity = discount_quantity(offer.offer_type)
        number_of_x = quantity_as_int / discount_quantity


        discount = discount(unit_price, quantity, offer, number_of_x, quantity_as_int, product, discount_quantity)
        
    
        receipt.add_discount(discount) if discount
    end

    private

    def quantity
      @quantity ||= product_quantities[product]
    end

    def discount(unit_price, quantity, offer, number_of_x, quantity_as_int, product, discount_quantity)
        if two_for_amount?(offer)
            return two_for_amount(offer, quantity_as_int, discount_quantity, unit_price, quantity, product)
          end
          if three_for_two?(offer)
            return three_for_two(quantity, unit_price, number_of_x, quantity_as_int, product)
          end
          if ten_percent?(offer)
            return ten_percent(product, offer, quantity, unit_price)
          end
          if five_for_amount?(offer)
            return five_for_amount(unit_price, quantity, offer, number_of_x, quantity_as_int, product, discount_quantity)
          end
    end

    def two_for_amount?(offer)
        offer.offer_type == Kata::SpecialOfferType::TWO_FOR_AMOUNT
    end

    def three_for_two?(offer)
        offer.offer_type == Kata::SpecialOfferType::THREE_FOR_TWO
    end

    def ten_percent?(offer)
        offer.offer_type == Kata::SpecialOfferType::TEN_PERCENT_DISCOUNT
    end

    def five_for_amount?(offer)
        offer.offer_type == Kata::SpecialOfferType::FIVE_FOR_AMOUNT
    end

    def discount_quantity(offer_type)
      Hash.new(1).tap { |h|
            h[Kata::SpecialOfferType::TWO_FOR_AMOUNT] = 2
            h[Kata::SpecialOfferType::THREE_FOR_TWO] = 3
            h[Kata::SpecialOfferType::FIVE_FOR_AMOUNT] = 5
          }[offer_type]
    end
  
    def two_for_amount(offer, quantity_as_int, discount_quantity, unit_price, quantity, product)
      return unless quantity_as_int >= 2

      total = offer.argument * (quantity_as_int / discount_quantity) + quantity_as_int % 2 * unit_price
      discount_n = unit_price * quantity - total
      Kata::Discount.new(product, "2 for " + offer.argument.to_s, discount_n)
    end
  
    def three_for_two(quantity, unit_price, number_of_x, quantity_as_int, product)
      return unless quantity_as_int > 2

      discount_amount = quantity * unit_price - ((number_of_x * 2 * unit_price) + quantity_as_int % 3 * unit_price)
      Kata::Discount.new(product, "3 for 2", discount_amount)
    end
  
    def ten_percent(product, offer, quantity, unit_price)
      Kata::Discount.new(product, offer.argument.to_s + "% off", quantity * unit_price * offer.argument / 100.0)
    end
  
    def five_for_amount(unit_price, quantity, offer, number_of_x, quantity_as_int, product, discount_quantity)
      return unless quantity_as_int >= 5

      discount_total = unit_price * quantity - (offer.argument * number_of_x + quantity_as_int % 5 * unit_price)
      Kata::Discount.new(product, discount_quantity.to_s + " for " + offer.argument.to_s, discount_total)
    end
end