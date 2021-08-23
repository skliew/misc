require 'minitest/autorun'

# Modeled after the #resolve method in https://github.com/evanphx/talon/blob/master/grammar.kpeg
class PrecedenceResolver
  @@precedence = {
    '*' => 8,
    '/' => 8,
    '+' => 7,
    '-' => 7,
    '==' => 10,
    '=' => 0,
    '&&' => 3,
    '||' => 2,
    nil => 100,
  }

  # Not used for now
  @@assoc = {
    '=' => :right,
    '<<' => :left
  }

  def precedence(op)
    if level = @@precedence[op]
      level
    else
      5
    end
  end

  def resolve(input)
    return input[0] if input.length == 1

    lhs, op, *rest = input

    next_i, next_op, *next_rest = rest

    if precedence(op) >= precedence(next_op)
      binary(binary(lhs, op, next_i), next_op, resolve(next_rest))
    else
      binary(lhs, op, resolve(rest))
    end
  end

  #     resolve(nil, 1, [+, 2, *, 3])
  #     | resolve(+, 2, [*, 3])
  #     | | resolve(*, 3, [])
  #     | | `-> [3, []]
  #     | `-> resolve(+, binary(2, 3, *), [])
  #     |     `-> [(2 * 3), []]
  #     `-> resolve(nil, binary(1, (2 * 3), +), [])
  #         `-> [(1 + (2 * 3)), [])
 
  #     resolve(nil, 1, [*, 2, +, 3, *, 4])
  #     | b = *, e2 = 2
  #     | resolve(*, 2, [+, 3, *, 4])
  #     | | b = +, which prec is less than *
  #     | `-> [2, [+, 3, *, 4]]
  #     | e3 = 2, rest3 = [+, 3, *, 4]
  #     `-> resolve(nil, binary(1, 2, *), [+, 3, *, 4])
  #         | b = +, e2 = 3
  #         | resolve(+, 3, [*, 4])
  #         | | b = *, e2 = 4
  #         | | resolve(*, 4, [])
  #         | | `-> [4, []]
  #         | | resolve(+, binary(3, *, 4), [])
  #         | `-> [binary(3, *, 4), []]
  #         | e3 = binary(3, *, 4), rest3 = []
  #         `-> resolve(nil, binary(binary(1, 2, *), binary(3, *, 4), +), [])
  #             `-> [binary(binary(1, 2, *), binary(3, *, 4), +), []]
  def resolve_with_chain(a, e, chain)
    return [e, []] if chain.empty?

    b, *rest = chain

    # a is mainly for its precedence
    if a && precedence(a) > precedence(b)
      return [e, chain]
    else
      # Get the next expression
      e2, *rest2 = rest
      # Resolve with b as the current precedence
      e3, rest3 = resolve_with_chain(b, e2, rest2)

      resolve_with_chain(a, binary(e, b, e3), rest3)
    end
  end

  def binary(lhs, o, rhs)
    Binary.new(lhs, o, rhs)
  end
end

Binary = Struct.new(:lhs, :op, :rhs)

class PrecedenceResolverTest < Minitest::Test
  def setup
    @subject = PrecedenceResolver.new
  end

  def test_resolve_simple
    result = @subject.resolve([1])
    assert_equal 1, result
  end

  def test_resolve_simple_binary
    result = @subject.resolve([1, '+', 2])
    assert_equal Binary.new(1, '+', 2), result
  end

  def test_resolve_binary_with_multi
    result = @subject.resolve([1, '+', 2, '*', 3])
    assert_equal Binary.new(1, '+', Binary.new(2, '*', 3)), result
  end

  def test_resolve_binary_with_multi_2
    result = @subject.resolve([1, '*', 2, '+', 3])
    assert_equal Binary.new(Binary.new(1, '*', 2), '+', 3), result
  end

  def test_resolve_binary_with_multi_3
    result = @subject.resolve([1, '*', 2, '+', 3, '*', 4])
    assert_equal Binary.new(Binary.new(1, '*', 2), '+', Binary.new(3, '*', 4)), result
  end

  def test_resolve_with_chain_simple
    result = @subject.resolve_with_chain(nil, 1, [])
    assert_equal [1, []], result
  end

  def test_resolve_with_chain_with_multi_3
    result = @subject.resolve_with_chain(nil, 1, ['*', 2, '+', 3, '*', 4])
    assert_equal [Binary.new(Binary.new(1, '*', 2), '+', Binary.new(3, '*', 4)), []], result
  end
end
