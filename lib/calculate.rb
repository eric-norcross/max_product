# Yields the maximum product of 3 values when given 3 or more qualifying numbers
class Calculate
  MINIMUM_LENGTH              = 3
  ERROR_INPUT_IS_NOT_AN_ARRAY = 'Input is not an array'.freeze
  ERROR_INSUFFICIENT_INPUT    = 'Input must contain at least 3 numbers'.freeze

  def self.max_product(set = [])
    # Valid arguments are inputs which can be converted to an array using
    # `::try_convert` (which is more restrictive than `.to_a`)

    # Sanitize input
    set = filter_set(validate_set(set))

    # Ensure minimum input length or raise error
    set.length >= MINIMUM_LENGTH || alert(ERROR_INSUFFICIENT_INPUT)

    # Convert subset of numbers to Integers and multiply them together
    # This can be further optimized if we restrict input to Integers only.
    # See comments in `qualified_number?` method.
    a = (set.min(2) + set.max(1)).map(&:to_i).inject(:*)
    b = set.max(3).map(&:to_i).inject(:*)

    # Compare the two subsets and return whichever is greater
    a > b ? a : b
  end

  def self.validate_set(set)
    # Attempts to convert the set to an array
    # If it can't be converted, returns `nil` and raises error

    # Alternatively, we could be more lenient with our input by
    # trying to convert the input with `.to_a`
    Array.try_convert(set) || alert(ERROR_INPUT_IS_NOT_AN_ARRAY)
  end

  def self.filter_set(set)
    # Performance can be further optimized by removing `flatten` thereby
    # rejecting nested arrays in the `qualified_number?` method
    set.flatten.keep_if { |n| qualified_number? n }
  end

  def self.qualified_number?(n)
    # Qualified numbers are Integers, or Floats which are equal to
    # themselves when converted to an Integer (e.g.: 1.0 == 1 but 1.1 != 1)

    # The performance of `max_product` can be optimized considerably
    # if we outright reject any non Integer as opposed to trying to
    # convert Floats. However, it may be negligible depending on the
    # size of the data set.
    # For example, n.is_a?(Integer) yields:
    #   <Benchmark::Tms:0x007fb9f08239b0 @label="", @real=8.999998681247234e-05, @cstime=0.0, @cutime=0.0, @stime=0.0, @utime=0.0, @total=0.0>
    # Where as the below yields:
    #   <Benchmark::Tms:0x007f88990507c0 @label="", @real=0.00011399993672966957, @cstime=0.0, @cutime=0.0, @stime=0.0, @utime=0.0, @total=0.0>

    # Numeric Types
    #   - Integer
    #   - Float
    #   - Rational
    #   - Complex
    #   - BigDecimal (Not part of Ruby Core)

    n.is_a?(Integer) || (
      n.is_a?(Float) && # Rejects non Floats (Including Rational, Complex, & BigDecimal numbers)
      n.finite?      && # Rejects infinite numbers (+/- infinity)
      !n.nan?        && # Rejects NaN Floats
      n == n.to_i       # Rejects Floats which are not equal to themselves when converted to an Integer (e.g.: 1.0 == 1 but 1.1 != 1)
    )
  end

  def self.alert(message)
    raise StandardError, message
  end
end
