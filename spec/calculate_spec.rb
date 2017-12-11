# spec/calculate_spec.rb
require 'calculate'

describe Calculate do
  # Valid numbers are Integers, or Floats which are equal to
  # themselves when converted to an Integer (e.g.: 1.0 == 1 but 1.1 != 1)
  INTEGERS            = [1, 7, -100, 0].freeze
  VALID_FLOATS        = [2.5E4, 0.1E1, 0.0, Float::DIG, Float::MANT_DIG, Float::MAX_10_EXP, Float::MAX_EXP, Float::MIN_10_EXP, Float::MIN_EXP, Float::RADIX, Float::ROUNDS].freeze
  
  INVALID_FLOATS      = [(2.0 / 3.4), 5.3, -3.6, 0.34, Float::EPSILON, Float::MIN, Float::NAN, Float::INFINITY, (+1.0 / 0.0), (-1.0 / 0.0), (0.0 / 0.0)].freeze
  INVALID_NUMERICS    = [Math::PI, Math::E, Complex::I, Complex(0.3), Complex('0.3-0.5i'), Complex('2/3+3/4i'), Complex('1@2'), Rational(2, 3), Rational(13)].freeze
  
  # Valid arguments are inputs which can be converted to an array using
  # `::try_convert` (which is more restrictive than `.to_a`)
  VALID_ARGUEMENTS    = [[], %w(), %i(), [1, 2, 3].freeze].freeze
  INVALID_ARGUEMENTS  = [true, false, nil, :test, 'test', '18', { k: 17 }, "#{[1, 2, 3]}"].freeze

  # Valid Numerics; Used to simplify calculating expected result
  MAX_VALUE_ENTRIES   = [Float::MAX, 147_279_103, 2<<64].freeze 
  
  VALID_ENTRIES       = INTEGERS + VALID_FLOATS + MAX_VALUE_ENTRIES
  INVALID_ENTRIES     = INVALID_FLOATS + INVALID_NUMERICS + INVALID_ARGUEMENTS

  VALID_SET           = VALID_ENTRIES + INVALID_ENTRIES
  FILTERED_SET        = VALID_ENTRIES
  
  it { is_expected.to be_an(Calculate) }

  describe 'const MINIMUM_LENGTH' do
    it 'is equal to 3' do
      expect(Calculate::MINIMUM_LENGTH).to eq(3)
    end
  end

  describe '.validate_set' do
    context 'when given an argument' do
      invalid_arguments = INVALID_ARGUEMENTS + [1]
      valid_arguments   = VALID_ARGUEMENTS + [VALID_SET]

      invalid_arguments.each do |invalid_argument|
        it 'raises an error if invalid' do
          expect { Calculate.validate_set(invalid_argument) }.to raise_error(StandardError)
        end
      end

      valid_arguments.each do |valid_argument|
        it 'returns an array if valid' do
          expect(Calculate.validate_set(valid_argument)).to be_an_instance_of(Array)
        end
      end
    end
  end

  describe '.filter_set' do
    context 'when given multiple types' do
      it 'filters out invalid input' do
        expect(Calculate.filter_set(VALID_SET)).to match_array(FILTERED_SET)
      end
    end
  end

  describe '.qualified_number?' do
    context 'when given an entry' do
      INVALID_ENTRIES.each do |invalid_entry|
        it 'returns false for invalid entries' do
          expect(Calculate.qualified_number?(invalid_entry)).to be false
        end
      end

      VALID_ENTRIES.each do |valid_entry|
        it 'returns true for valid entries' do
          expect(Calculate.qualified_number?(valid_entry)).to be true
        end
      end
    end
  end

  describe '.max_product' do
    context 'when given set with less than the minimum input' do
      it 'raises an error' do
        expect { Calculate.max_product(VALID_ENTRIES.take(2)) }.to raise_error(StandardError)
      end
    end

    context 'when given an invalid set' do
      it 'raises an error' do
        expect { Calculate.max_product(INVALID_ENTRIES) }.to raise_error(StandardError)
      end
    end

    context 'when given a valid set' do
      calculated_sets = [
        { assert: VALID_SET,                      expected: MAX_VALUE_ENTRIES.map(&:to_i).inject(:*) },
        { assert: [1, 3, 7, 9],                   expected: 189 },
        { assert: [1, 3, -7, 9],                  expected: 27 },
        { assert: [3, -9, 7, 12],                 expected: 252 },
        { assert: [-2, -3, -4, -5],               expected: -24 },
        { assert: [2, 5, 1, ['four', 4]],         expected: 40 },
        { assert: [1, 3, 0, 300],                 expected: 900 },
        { assert: [1, 3, 0],                      expected: 0 },
        { assert: [0, 0, 0],                      expected: 0 },
        { assert: [0.0, 0, 0, 0.00],              expected: 0 },
        { assert: [1, 1, 1],                      expected: 1 },
        { assert: [1, 1, 1, 300],                 expected: 300 },
        { assert: [-1, 1, 1],                     expected: -1 },
        { assert: [Float::MAX, 1, 1],             expected: Float::MAX.to_i },
        { assert: [Float::MAX, Float::MAX, 50],   expected: Float::MAX.to_i * Float::MAX.to_i * 50 },
        { assert: [-5, -53, -300, -10],           expected: -2650 },
        { assert: [-1, -5, -53, -300, 10],        expected: 159_000 },
        { assert: [-0, -53, -300],                expected: 0 },
        { assert: [2 / 3, 10, 15],                expected: 0 },
        { assert: [2.0 / 3.0, 10, 15, -2],        expected: -300 }
      ]

      calculated_sets.each do |pair|
        it 'returns the expected result' do
          expect(Calculate.max_product(pair[:assert])).to eql(pair[:expected])
        end
      end
    end
  end
end
